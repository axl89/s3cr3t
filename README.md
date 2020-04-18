# s3cr3t
Serve files securely from an S3 bucket with expiring links and other restrictions

## WIP list

- NGINX security hardening.
- Configure NGINX site with TLS.
- Be able to change the `/s` URIs
- Improve docs
- Allow links to be created without client IP restriction
- Allow links to be created without time expiration
- Limit the amount of downloads per IP address
- ~~Be able to use Private S3 buckets~~



## Building the image

```
 export AWS_ACCESS_KEY_ID=1234
 export AWS_SECRET_ACCESS_KEY=5678
 export SECRET=CHANGEMEforducksake
 export S3_BUCKET_NAME=your-bucket
 export BUCKET_REGION=us-east-1

docker build \
--build-arg AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
--build-arg AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
--build-arg SECRET=$SECRET \
--build-arg S3_BUCKET_NAME=$S3_BUCKET_NAME \
--build-arg BUCKET_REGION=$BUCKET_REGION \
-t s3cr3t/s3cr3t-server .
```

## Getting a link

### Installing prerequisites

```
apt update && apt install python3 python3-pip -y
pip3 install -r requirements.txt
```

### Using the secret-link-generator utility


```
./secret-link-generator.py \
-p /s/oneregularfile.tar.gz \
-r 172.17.0.1 \
-h http://localhost:9090 \
-s CHANGEMEforducksake
```

Will return:

`http://localhost:9090/s/oneregularfile.tar.gz?md5=v-qpUxhRuDeNVTdFQzTfhA&expires=1584897454`

__Warning__: If the `-e` argument is not specified, the link will have a default duration of 1h.
