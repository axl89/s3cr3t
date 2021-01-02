#!/usr/bin/env python3

"""
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
"""

from datetime import datetime, timedelta, timezone
from base64 import b64encode
import hashlib
import click

def get_url_prefix(has_expiration,has_remote_address,has_uri_check = True):
    prefix = '/'

    if has_expiration:
        prefix += 's'
    if has_uri_check:
        prefix += 'u'
    if has_remote_address:
        prefix += 'r'

    return prefix
def forge_link(resource, secret, host, expire_epoch, client_remote_addr = None):
    uncoded = ''

    if expire_epoch is not None:
        uncoded += expire_epoch

    prefix = get_url_prefix(expire_epoch is not None, client_remote_addr is not None)

    uncoded += prefix + '/' + resource

    if client_remote_addr is not None:
        uncoded += client_remote_addr

    uncoded += ' ' + secret

    uncoded = uncoded.encode()

    #md5 the previous information
    md5hashed = hashlib.md5(uncoded).digest()

    # Base64 encode and transform the string
    b64 = b64encode(md5hashed)
    unpadded_b64url = b64.replace(b'+', b'-').replace(b'/', b'_').replace(b'=', b'')

    # Format and generate the link
    if expire_epoch:
        linkformat = "{}{}/{}?md5={}&expires={}"
        securelink = linkformat.format(
            host,
            prefix,
            resource,
            unpadded_b64url.decode(),
            expire_epoch
        )
    else:
        linkformat = "{}{}/{}?md5={}"
        securelink = linkformat.format(
            host,
            prefix,
            resource,
            unpadded_b64url.decode()
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
@click.option('--file', '-f', required=True, type=click.STRING, help='Full path of the file, relative to the root of the S3 bucket')
@click.option('--remote_address', '-r', type=click.STRING, help='IP address of the client')
@click.option('--server_url', '-u', required=True, type=click.STRING, help='Full URL of the s3cr3t server')
@click.option('--secret', '-s', required=True, prompt=True, hide_input=True, confirmation_prompt=True, type=click.STRING, help='Secret configured in NGINX')
@click.option('--expiration_timestamp', '-e', default=get_expiration_default_value(), type=click.STRING, help=' Link\'s expiration timestamp', show_default=True)
def generate_link(file, remote_address, server_url, secret, expiration_timestamp):
    """
    Generates a s3cr3t link.

    Example:

    ./secret-link-generator.py -f onefile.tar.gz -u http://localhost:9090 -s mysecret
    """
    if expiration_timestamp == 'never':
        expiration_timestamp = None
    forge_link(file, secret, server_url, expiration_timestamp, remote_address)


if __name__ == '__main__':
    generate_link()
