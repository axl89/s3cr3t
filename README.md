# s3cr3t
Serve files securely from an S3 bucket with expiring links and other restrictions

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

## Running the image

Just run it with Docker:

`docker run --rm -it -p9090:80 s3cr3t/s3cr3t-server`

Support for Kubernetes deployment is on the way.


## How does it work

First, install the required requisites for python3 to work.

```
apt update && apt install python3 python3-pip -y
pip3 install -r requirements.txt
```

Then, generate a link using the `secret-link-generator.py` utility.

__Warning__: If the `-e` argument is not specified, the link will have a default duration of 1h.

### With client IP address restriction, and expiration in 1h

```
./secret-link-generator.py \
-f oneregularfile.tar.gz \
-r 172.17.0.1 \
-u http://localhost:9090 \
-s CHANGEMEforducksake
```

Will return: `http://localhost:9090/sur/oneregularfile.tar.gz?md5=Z8Dwsj1o4aTSbXHsLFeocQ&expires=1587238255`

### Without client IP address restriction, and expiration in 1h

```
./secret-link-generator.py \
-f oneregularfile.tar.gz \
-u http://localhost:9090 \
-s CHANGEMEforducksake
```

Will return: `http://localhost:9090/su/oneregularfile.tar.gz?md5=sUfTXNUYK3dRNm1jAdmq4A&expires=1587238234`

### Without expiration

```
./secret-link-generator.py \
-f oneregularfile.tar.gz \
-u http://localhost:9090 \
-s CHANGEMEforducksake \
-e 1609419599
```

### With specific expiration (i.e:31st of December at 23:59:59)


Will return: `http://localhost:9090/su/oneregularfile.tar.gz?md5=nUi5yQNGt5O5dkcDQQ9NXA&expires=1609419599`

