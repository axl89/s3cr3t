# s3cr3t: a supercharged S3 reverse proxy
Serve files securely from an S3 bucket with expiring links and other restrictions.

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggTFJcblx0QVtDbGllbnRdIC0tPnxHRVQgL2ZpbGUudGFyLmd6fCBCKHMzY3IzdCBzZXJ2ZXIpXG5cdEIgLS0-IEN7Q2hlY2tzfVxuXHRDIC0tPnxVUkkgbWF0Y2g_fCBEXG5cdEMgLS0-fElQIGFsbG93ZWQ_fCBEXG5cdEMgLS0-fEV4cGlyZWQ_fCBEXG4gICAgRChTMyBCdWNrZXQpXG4gICAgRC0uIFJlc3BvbnNlIC4tPiBCXG4gICAgQi0uIFJlc3BvbnNlIC4tPiBBXG5cdFx0XHRcdFx0IiwibWVybWFpZCI6eyJ0aGVtZSI6ImRlZmF1bHQifSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggTFJcblx0QVtDbGllbnRdIC0tPnxHRVQgL2ZpbGUudGFyLmd6fCBCKHMzY3IzdCBzZXJ2ZXIpXG5cdEIgLS0-IEN7Q2hlY2tzfVxuXHRDIC0tPnxVUkkgbWF0Y2g_fCBEXG5cdEMgLS0-fElQIGFsbG93ZWQ_fCBEXG5cdEMgLS0-fEV4cGlyZWQ_fCBEXG4gICAgRChTMyBCdWNrZXQpXG4gICAgRC0uIFJlc3BvbnNlIC4tPiBCXG4gICAgQi0uIFJlc3BvbnNlIC4tPiBBXG5cdFx0XHRcdFx0IiwibWVybWFpZCI6eyJ0aGVtZSI6ImRlZmF1bHQifSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)

## Running the container

Modify the `env_file` first and then run it with Docker:

```bash
docker run --env-file=env_file --rm -it -p9090:80 s3cr3t/s3cr3t-server
```

Support for Kubernetes deployment is on the way.


## How to generate s3cr3t links

First, install the required requisites for python3 to work.

```bash
apt update && apt install python3 python3-pip -y
pip3 install -r requirements.txt
```

Then, generate a link using the `secret-link-generator.py` utility.

__Warning__: If the `-e` argument is not specified, the link will have a default duration of 1h.

### With client IP address restriction, and expiration in 1h

```bash
./secret-link-generator.py \
-f oneregularfile.tar.gz \
-r 172.17.0.1 \
-u http://localhost:9090 \
-s CHANGEMEforducksake
```

Will return: `http://localhost:9090/sur/oneregularfile.tar.gz?md5=Z8Dwsj1o4aTSbXHsLFeocQ&expires=1587238255`


### Without client IP address restriction, and expiration in 1h

```bash
./secret-link-generator.py \
-f oneregularfile.tar.gz \
-u http://localhost:9090 \
-s CHANGEMEforducksake
```

Will return: `http://localhost:9090/su/oneregularfile.tar.gz?md5=sUfTXNUYK3dRNm1jAdmq4A&expires=1587238234`


### Without expiration

```bash
./secret-link-generator.py \
-f oneregularfile.tar.gz \
-u http://localhost:9090 \
-s CHANGEMEforducksake \
-e never
```

Will return: `http://localhost:9090/u/oneregularfile.tar.gz?md5=isbd6KzU2e7BnzgIMpikhQ`


### With specific expiration (i.e:31st of December at 23:59:59)

```bash
./secret-link-generator.py \
-f oneregularfile.tar.gz \
-u http://localhost:9090 \
-s CHANGEMEforducksake \
-e 1609419599
```

Will return: `http://localhost:9090/su/oneregularfile.tar.gz?md5=nUi5yQNGt5O5dkcDQQ9NXA&expires=1609419599`
