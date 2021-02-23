FROM node:14-alpine as base

ARG VERSION

RUN \
  apk update && \
  apk upgrade && \
  apk add bash ssmtp util-linux

SHELL ["/bin/bash", "-c"]

WORKDIR /directus



FROM base as development

RUN rm -rf /var/cache/apk/*

ENTRYPOINT ["config/docker-entrypoint.sh"]