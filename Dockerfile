FROM alpine:3.12

# Install some tools
# python is required for gsutil
RUN set -x \
  && apk add --update bash findutils postgresql-client gzip bzip2 lz4 xz unzip zip coreutils python3 rsync \
  && rm -rf /var/cache/apk/* \
  && ln -s /usr/bin/python3 /usr/bin/python \
  ;

# Install Panubo bash-container
RUN set -x \
  && BASHCONTAINER_VERSION=0.6.0 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && if ! command -v gpg > /dev/null; then \
      fetchDeps="${fetchDeps} gnupg"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz.asc \
  && GPG_KEYS="E51A4070A3FFBD68C65DDB9D8BECEF8DFFCC60DD" \
  && ( gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$GPG_KEYS" ) \
  && gpg --batch --verify panubo-functions.tar.gz.asc panubo-functions.tar.gz  \
  && tar -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apk del ${fetchDeps} \
  ;

ENV \
  GSUTIL_VERSION=4.46 \
  GSUTIL_CHECKSUM=bb319cc49d74cf12b692748d498abc63e6098750fb6e36cff71eebf71ec895e0 \
  CLOUDSDK_GSUTIL_PYTHON=python3 \
  CLOUDSDK_PYTHON=python3

# Install gsutil
RUN set -x \
  && mkdir -p /opt \
  && curl -o /tmp/gsutil_${GSUTIL_VERSION}.tar.gz "https://storage.googleapis.com/pub/gsutil_${GSUTIL_VERSION}.tar.gz" \
  && echo "${GSUTIL_CHECKSUM}  gsutil_${GSUTIL_VERSION}.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && tar -C /opt -zxf /tmp/gsutil_${GSUTIL_VERSION}.tar.gz \
  && ln -s /opt/gsutil/gsutil /usr/local/bin/gsutil \
  && rm -f /tmp/* \
  && find /opt ! -group 0 -exec chgrp -h 0 {} \; \
  ;

ENV \
  PYTHONIOENCODING=UTF-8 \
  PYTHONUNBUFFERED=0 \
  PAGER=more \
  AWS_CLI_VERSION=1.16.286 \
  AWS_CLI_CHECKSUM=7e99ea733b3d97b1fa178fab08b5d7802d0647ad514c14221513c03ce920ce83

RUN set -x \
  && apk add --no-cache ca-certificates wget \
  && cd /tmp \
  && wget -nv https://s3.amazonaws.com/aws-cli/awscli-bundle-${AWS_CLI_VERSION}.zip -O /tmp/awscli-bundle-${AWS_CLI_VERSION}.zip \
  && echo "${AWS_CLI_CHECKSUM}  awscli-bundle-${AWS_CLI_VERSION}.zip" > /tmp/SHA256SUM \
  && sha256sum -c SHA256SUM \
  && unzip awscli-bundle-${AWS_CLI_VERSION}.zip \
  && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && apk del wget \
  && rm -rf /tmp/* \
  ;

COPY commands /usr/local/bin/

CMD ["usage"]
