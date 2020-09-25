#!/bin/bash
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

set -eu
set -o pipefail

# Sed env into NGINX files
sed -i s/your-bucket-name/$S3_BUCKET_NAME/g /etc/nginx/conf.d/default.conf
sed -i s/your-bucket-region/$BUCKET_REGION/g /etc/nginx/conf.d/default.conf
sed -i s/AM1ghtyS3cr3t\!/$SECRET/g /etc/nginx/conf.d/default.conf

## NGINX global config
sed -i s/INVALID_AWS_ACCESS_KEY_ID/$AWS_ACCESS_KEY_ID/g /usr/local/openresty/nginx/conf/nginx.conf
sed -i s/INVALID_AWS_SECRET_ACCESS_KEY/$AWS_SECRET_ACCESS_KEY/g /usr/local/openresty/nginx/conf/nginx.conf


# Start server (see https://github.com/openresty/docker-openresty/blob/fb4428f216d230847e39fa6e79dc598663a63846/buster/Dockerfile#L59)
/usr/bin/openresty -g 'daemon off;';