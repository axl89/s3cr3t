# s3cr3t
Serve files securely from an S3 bucket with expiring links and other restrictions

## WIP list

- Be able to use Private S3 buckets
- Be able to change the /s and /s/cached URIs
- Improve docs
- Allow links to be created without client IP restriction
- Allow links to be created without time expiration


## Building the image

`docker build --build-arg SECRET=CHANGEMEforducksake --build-arg S3_BUCKET=a-public-bucket.s3.amazonaws.com -t wh03v3r/s3cr3t-server .`

## Getting a link

If the `-e` argument is not specified, the link will have a default duration of 1h.

### Without cache

`./link-generator-example.py -p /s/oneregularfile.tar.gz -r 172.17.0.1 -h http://localhost:9090 -s CHANGEMEforducksake`


### With cache

`./link-generator-example.py -p /s/cached/oneregularfile.tar.gz -r 172.17.0.1 -h http://localhost:9090 -s CHANGEMEforducksake`
