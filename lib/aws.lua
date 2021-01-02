--[[
    Copyright (C) 2021  Axel Amigo Arnold

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local cjson = require 'cjson'
local resty_hmac = require 'resty.hmac'
local resty_sha256 = require 'resty.sha256'
local str = require 'resty.string'

local setmetatable = setmetatable
local error = error

local _M = { _VERSION = '0.1.0' }
local mt = { __index = _M }

local function get_credentials ()
  local access_key = os.getenv('AWS_ACCESS_KEY_ID')
  local secret_key = os.getenv('AWS_SECRET_ACCESS_KEY')
  if access_key ~= nil and secret_key ~= nil then
    return {
      access_key = access_key,
      secret_key = secret_key
    }
  end

  local res = ngx.location.capture('/_meta-data/iam/security-credentials/')
  if res.status ~= ngx.HTTP_OK then
    return
  end

  res = ngx.location.capture('/_meta-data/iam/security-credentials/' .. res.body)
  if res.status ~= ngx.HTTP_OK then
    return
  end

  local creds = cjson.decode(res.body)
  if creds['Type'] ~= 'AWS-HMAC' or creds['Code'] ~= 'Success' then
    return
  end

  return {
    access_key = creds['AccessKeyId'],
    secret_key = creds['SecretAccessKey'],
    security_token = creds['Token']
  }
end

local function get_iso8601_basic(timestamp)
  return os.date('!%Y%m%dT%H%M%SZ', timestamp)
end

local function get_iso8601_basic_short(timestamp)
  return os.date('!%Y%m%d', timestamp)
end
local function get_cred_scope(timestamp, region, service)
  return get_iso8601_basic_short(timestamp)
    .. '/' .. region
    .. '/' .. service
    .. '/aws4_request'
end

local function get_signed_headers()
  return 'host;x-amz-content-sha256;x-amz-date'
end

local function get_sha256_digest(s)
  local h = resty_sha256:new()
  h:update(s or '')
  return str.to_hex(h:final())
end

local function get_hashed_canonical_request(timestamp, host, uri)
  local digest = get_sha256_digest(ngx.var.request_body)
  local canonical_request = ngx.var.request_method .. '\n'
    .. uri .. '\n'
    .. '\n'
    .. 'host:' .. host .. '\n'
    .. 'x-amz-content-sha256:' .. digest .. '\n'
    .. 'x-amz-date:' .. get_iso8601_basic(timestamp) .. '\n'
    .. '\n'
    .. get_signed_headers() .. '\n'
    .. digest
  return get_sha256_digest(canonical_request)
end

local function get_string_to_sign(timestamp, region, service, host, uri)
  return 'AWS4-HMAC-SHA256\n'
    .. get_iso8601_basic(timestamp) .. '\n'
    .. get_cred_scope(timestamp, region, service) .. '\n'
    .. get_hashed_canonical_request(timestamp, host, uri)
end

local function hmac_sha256_digest(key, content, hex_output)
  return resty_hmac:new(key, resty_hmac.ALGOS.SHA256):final(content, hex_output)
end

local function hmac_sha256_hexdigest(key, content)
  return hmac_sha256_digest(key, content, true)
end

local function get_derived_signing_key(keys, timestamp, region, service)
  local k_date = hmac_sha256_digest('AWS4' .. keys['secret_key'], get_iso8601_basic_short(timestamp))
  local k_region = hmac_sha256_digest(k_date, region)
  local k_service = hmac_sha256_digest(k_region, service)
  return hmac_sha256_digest(k_service, 'aws4_request')
end

local function get_authorization(keys, timestamp, region, service, host, uri)
  local derived_signing_key = get_derived_signing_key(keys, timestamp, region, service)
  local string_to_sign = get_string_to_sign(timestamp, region, service, host, uri)
  local auth = 'AWS4-HMAC-SHA256 '
    .. 'Credential=' .. keys['access_key'] .. '/' .. get_cred_scope(timestamp, region, service)
    .. ', SignedHeaders=' .. get_signed_headers()
    .. ', Signature=' .. hmac_sha256_hexdigest(derived_signing_key, string_to_sign)
  return auth
end

local function get_service_and_region(host)
  local patterns = {
    {'s3.amazonaws.com', 's3', 'us-east-1'},
    {'s3-external-1.amazonaws.com', 's3', 'us-east-1'},
    {'s3%-([a-z0-9-]+)%.amazonaws%.com', 's3', nil},
    {'s3%.([a-z0-9-]+)%.amazonaws%.com', 's3', nil}
  }
  for i,data in ipairs(patterns) do
    local region = host:match(data[1])
    if region ~= nil and data[3] == nil then
      return data[2], region
    elseif region ~= nil then
      return data[2], data[3]
    end
  end
  return nil, nil
end

local function aws_set_headers(host, uri)
  local creds = get_credentials()
  local timestamp = tonumber(ngx.time())
  local service, region = get_service_and_region(host)
  local auth = get_authorization(creds, timestamp, region, service, host, uri)

  ngx.req.set_header('Authorization', auth)
  ngx.req.set_header('Host', host)
  ngx.req.set_header('x-amz-date', get_iso8601_basic(timestamp))
  if creds['security_token'] ~= nil then
    ngx.req.set_header('x-amz-security-token', creds['security_token'])
  end
end

local function s3_set_headers(host, uri)
  aws_set_headers(host, uri)
  ngx.req.set_header('x-amz-content-sha256', get_sha256_digest(ngx.var.request_body))
end

_M.aws_set_headers = aws_set_headers
_M.s3_set_headers = s3_set_headers

return _M