FROM alpine:3.8

RUN apk -Uuv add curl ca-certificates bash groff less python py-pip \
  && pip install --upgrade pip \
  && pip install awscli \
  && apk --purge -v del py-pip \
  && rm /var/cache/apk/*

COPY entrypoint.sh /home/
COPY concourse_entrypoint.sh /home/

VOLUME ["/home", "/concourse-keys", "/concourse-secrets"]

ENTRYPOINT ["/bin/bash", "/home/entrypoint.sh"]
