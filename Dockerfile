FROM alpine:3.17

# Install some tools
# python is required for gsutil
RUN set -x \
  && apk add --update bash findutils postgresql-client gzip bzip2 lz4 xz unzip zip coreutils python3 rsync curl \
  && rm -rf /var/cache/apk/* \
  ;

# Install Panubo bash-container
RUN set -x \
  && BASHCONTAINER_VERSION=0.7.2 \
  && BASHCONTAINER_SHA256=87c4b804f0323d8f0856cb4fbf2f7859174765eccc8b0ac2d99b767cecdcf5c6 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && echo "${BASHCONTAINER_SHA256}  panubo-functions.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum panubo-functions.tar.gz)"; exit 1; )) \
  && tar --no-same-owner -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apk del ${fetchDeps} \
  ;

# ENV \
#   GSUTIL_VERSION=4.46 \
#   GSUTIL_CHECKSUM=bb319cc49d74cf12b692748d498abc63e6098750fb6e36cff71eebf71ec895e0 \
#   CLOUDSDK_GSUTIL_PYTHON=python3 \
#   CLOUDSDK_PYTHON=python3
#
# # Install gsutil
# RUN set -x \
#   && mkdir -p /opt \
#   && curl -o /tmp/gsutil_${GSUTIL_VERSION}.tar.gz "https://storage.googleapis.com/pub/gsutil_${GSUTIL_VERSION}.tar.gz" \
#   && echo "${GSUTIL_CHECKSUM}  gsutil_${GSUTIL_VERSION}.tar.gz" > /tmp/SHA256SUM \
#   && ( cd /tmp; sha256sum -c SHA256SUM; ) \
#   && tar -C /opt -zxf /tmp/gsutil_${GSUTIL_VERSION}.tar.gz \
#   && ln -s /opt/gsutil/gsutil /usr/local/bin/gsutil \
#   && rm -f /tmp/* \
#   && find /opt ! -group 0 -exec chgrp -h 0 {} \; \
#   ;

# Install Gcloud SDK (required for gsutil workload identity authentication)
ENV \
  GCLOUD_VERSION=424.0.0 \
  GCLOUD_CHECKSUM=1fed39626f23352e0f97623d5009ff1bb6c4ffd3875c85f4205f309292696b18

RUN set -x \
  && apk --no-cache add python3 \
  && curl -o /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
  && echo "${GCLOUD_CHECKSUM}  google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz)"; exit 1; )) \
  && tar -C / -zxvf /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
  && /google-cloud-sdk/install.sh --quiet \
  && ln -s /google-cloud-sdk/bin/gcloud /usr/local/bin/ \
  && ln -s /google-cloud-sdk/bin/gsutil /usr/local/bin/ \
  && rm -rf /tmp/* /root/.config/gcloud \
  ;

# Install AWS CLI
ENV \
  PYTHONIOENCODING=UTF-8 \
  PYTHONUNBUFFERED=0 \
  PAGER=more \
  AWS_CLI_VERSION=1.27.103 \
  AWS_CLI_CHECKSUM=0fed454146160807e273c4fd9bb1d0ba0926e3fb8ed3fc55e9251ebd2d53407c

RUN set -x \
  && apk --update add --no-cache ca-certificates wget unzip \
  && cd /tmp \
  && wget -nv https://s3.amazonaws.com/aws-cli/awscli-bundle-${AWS_CLI_VERSION}.zip -O /tmp/awscli-bundle-${AWS_CLI_VERSION}.zip \
  && echo "${AWS_CLI_CHECKSUM}  awscli-bundle-${AWS_CLI_VERSION}.zip" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum awscli-bundle-${AWS_CLI_VERSION}.zip)"; exit 1; )) \
  && unzip awscli-bundle-${AWS_CLI_VERSION}.zip \
  && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && apk del wget \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  ;

COPY commands /usr/local/bin/

CMD ["usage"]
