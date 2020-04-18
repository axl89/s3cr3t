#!/usr/bin/env python3

"""
Copyright (C) 2020  Axel Amigo Arnold

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
"""

from datetime import datetime, timedelta, timezone
from base64 import b64encode
import hashlib
import click

def forge_link(resource, secret, host, expire_epoch, client_remote_addr = None):
    # md5 hash the string
    if client_remote_addr:
        uncoded = expire_epoch + resource + client_remote_addr + ' '.encode() + secret
    else:
        uncoded = expire_epoch + resource + ' '.encode() + secret
    md5hashed = hashlib.md5(uncoded).digest()

    # Base64 encode and transform the string
    b64 = b64encode(md5hashed)
    unpadded_b64url = b64.replace(b'+', b'-').replace(b'/', b'_').replace(b'=', b'')

    # Format and generate the link
    linkformat = "{}{}?md5={}&expires={}"
    securelink = linkformat.format(
    host.decode(),
    resource.decode(),
    unpadded_b64url.decode(),
    expire_epoch.decode()
    )

    # Print the link
    print(securelink)

def get_expiration_default_value():
    """
    1 hour in the future
    """
    now = datetime.now(timezone.utc)
    expire_dt = now + timedelta(hours=1)
    return str(int(expire_dt.timestamp()))

@click.command()
@click.option('--path', '-p', required=True, type=click.STRING, help='Full path to the S3 object')
@click.option('--remote_address', '-r', required=False, type=click.STRING, help='IP address of the client')
@click.option('--host_url', '-h', required=True, type=click.STRING, help='Full URL of the reverse proxy')
@click.option('--secret', '-s', required=True, prompt=True, hide_input=True, confirmation_prompt=True, type=click.STRING, help='Secret configured in NGINX')
@click.option('--expiration_timestamp', '-e', default=get_expiration_default_value(), type=click.STRING, help=' Link\'s expiration timestamp', show_default=True)
def generate_link(path, remote_address, host_url, secret, expiration_timestamp):
    """
    Generates a link that expires.

    Example:
      ./secret-link-generator.py -p /s/file.tar.gz -r 172.17.0.1 -h http://localhost:9090 -s changeme
    """
    if remote_address:
        forge_link(path.encode(), secret.encode(), host_url.encode(), expiration_timestamp.encode(), remote_address.encode())
    else:
        forge_link(path.encode(), secret.encode(), host_url.encode(), expiration_timestamp.encode())


if __name__ == '__main__':
    generate_link()
