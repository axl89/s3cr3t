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

# Copy required files

## NGINX
COPY nginx-site-example.conf /etc/nginx/conf.d/default.conf
COPY secret-site.conf /usr/local/openresty/nginx/conf/secret-site.conf
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY entrypoint.sh /tmp/entrypoint.sh

## Openresty
COPY lib/aws.lua /usr/local/openresty/lualib/resty/aws.lua
COPY lib/hmac.lua /usr/local/openresty/lualib/resty/hmac.lua

# Entrypoint that changes NGINX config files at runtime
# with the environment variables
CMD ["/tmp/entrypoint.sh"]