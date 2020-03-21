FROM nginx:1.17-alpine

ARG S3_BUCKET=a-bucket-name.s3.amazonaws.com
ARG SECRET

COPY nginx-cache-path.conf /etc/nginx/conf.d/nginx-cache-path.conf
COPY nginx-site-example.conf /etc/nginx/conf.d/default.conf

RUN sed -i s/your-bucket/$S3_BUCKET/g /etc/nginx/conf.d/default.conf
RUN sed -i s/AM1ghtyS3cr3t\!/$SECRET/g /etc/nginx/conf.d/default.conf
