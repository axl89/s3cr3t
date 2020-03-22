# Copyright (C) 2020  Axel Amigo Arnold

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

FROM openresty/openresty:buster

ARG S3_BUCKET_NAME=a-bucket-name
ARG SECRET
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG BUCKET_REGION=us-east-1


# Copy required files

## NGINX
COPY nginx-site-example.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

## Openresty
COPY lib/aws.lua /usr/local/openresty/lualib/resty/aws.lua
COPY lib/hmac.lua /usr/local/openresty/lualib/resty/hmac.lua


# Perform modifications based on arguments

## Site
RUN sed -i s/your-bucket-name/$S3_BUCKET_NAME/g /etc/nginx/conf.d/default.conf
RUN sed -i s/your-bucket-region/$BUCKET_REGION/g /etc/nginx/conf.d/default.conf
RUN sed -i s/AM1ghtyS3cr3t\!/$SECRET/g /etc/nginx/conf.d/default.conf

## NGINX global config
RUN sed -i s/INVALID_AWS_ACCESS_KEY_ID/$AWS_ACCESS_KEY_ID/g /usr/local/openresty/nginx/conf/nginx.conf
RUN sed -i s/INVALID_AWS_SECRET_ACCESS_KEY/$AWS_SECRET_ACCESS_KEY/g /usr/local/openresty/nginx/conf/nginx.conf
