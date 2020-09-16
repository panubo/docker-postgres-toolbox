FROM alpine:3.12

RUN set -x \
  && apk add --update bash findutils gzip postgresql-client \
  &&  rm -rf /var/cache/apk/* \
  ;

COPY commands /commands

ENTRYPOINT ["/commands/entry.sh"]

CMD ["default"]
