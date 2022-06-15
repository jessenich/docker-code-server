ARG BASE_IMAGE_TAG=latest
ARG SOURCE=localhost
ARG VERSION=local-latest

FROM node:lts-alpine:latest

LABEL maintainer="Jesse N. <jesse@keplerdev.com>" \
    org.opencontainers.image.source="$SOURCE" \
    org.opencontainers.image.version="$VERSION"

ENV BASE_IMAGE "node:lts-alpine" \
    BASE_IMAGE_TAG "$BASE_IMAGE_TAG" \
    SOURCE "$SOURCE" \
    VERSION "$VERSION"

COPY ./rootfs .

RUN apk add --update --no-cache \
    dumb-init \
    bash \
    ca-certificates \
    curl \
    jq \
    git \
    gnupg \
    gcc \
    sudo \
    zsh

SHELL [ "/bin/bash" ]

RUN /bin/bash /usr/local/sbin/install-code-server.sh && \
    chmod +x /usr/local/bin/docker && \
    addgroup coder && \
    adduser -G coder -s /bin/bash -D coder && \
    chown -R root:root /usr/local/bin

ENV CODE_SERVER_VERSION "$(cat /usr/local/sbin/VERSION)"
ENV SHELL=/bin/bash
USER coder
WORKDIR /home/coder

EXPOSE 4999
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "/usr/lib/code-server/out/node/entry.js", "--disable-updates", "--disable-telemetry", "--bind-addr", "0.0.0.0:4999", "."]
