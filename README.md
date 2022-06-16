# Docker Alpine Base Image

[![GitHub last commit](https://img.shields.io/github/last-commit/jessenich/docker-code-server?style=for-the-badge)](https://github.com/jessenich/docker-code-server/commit/57d54b3ff6bf4d6a7b72358eaf05b47b72ffdc6b) [![GitHub](https://img.shields.io/github/license/jessenich/docker-code-server?style=for-the-badge)](https://github.com/jessenich/docker-code-server/blob/master/LICENSE)

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/jessenich/docker-code-server/Push%20Docker%20Image?label=Build%20%26%20Push%20Docker%20Image&style=for-the-badge)

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/jessenich91/code-server?style=for-the-badge)](https://dockerhub.com/r/jessenich91/code-server) [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/jessenich91/code-server/latest?style=for-the-badge)](https://dockerhub.com/r/jessenich91/code-server) [![Docker Pulls](https://img.shields.io/docker/pulls/jessenich91/code-server?label=DOCKERHUB%20PULLS&style=for-the-badge)](https://dockerhub.com/r/jessenich91/code-server)

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod&style=for-the-badge)](https://gitpod.io/#https://github.com/jessenich/docker-code-server)

[__GitHub Source__](https://github.com/jessenich/docker-code-server)

Latest Tags:
`docker pull jessenich91/code-server:latest`
`docker pull jessenich91/code-server:alpine`
`docker pull jessenich91/code-server:debian`
`docker pull jessenich91/code-server:ubuntu`

[__DockerHub Registry__](https://dockerhub.com/r/jessenich91/code-server)

Latest Tags:
`docker pull ghcr.io/jessenich/code-server:latest`
`docker pull ghcr.io/jessenich/code-server:alpine`
`docker pull ghcr.io/jessenich/code-server:debian`
`docker pull ghcr.io/jessenich/code-server:ubuntu`

Version Specific (user/app:semver-compliant-version-tag:
`docker pull ghcr.io/jessenich/code-server:1.0.0-prerelease1+alpine3.14+codeserver4.4`
`docker pull ghcr.io/jessenich/code-server:alpine`
`docker pull ghcr.io/jessenich/code-server:debian`
`docker pull ghcr.io/jessenich/code-server:ubuntu`

## What is this image?

Baseline VS Code Server used in all my environment/language specific VSCode Server variants

### Image Meta

Based off node/lts-alpine:latest (Docs Updated: 06/15/2022).

Provisions default non root user defaulted to 'coder' with no password. Built against both Alpine 3.14 and 3.13 for amd64, aarch64, and armhf architectures.

## Running this Image

Run latest, standard variant.

`docker -rm -it ghcr.io/jessenich/alpine:latest`

To latest variant with non-root user, use `latest-sudo` tag:

`docker -rm -it ghcr.io/jessenich/alpine:latest-sudo`

You can attach `sudo` to any tag to get its non-root variant. Note: non-root variants have bash installed whereas root variants do not.

## License

Copyright (c) Jesse N. <jesse@keplerdev.com>. See [LICENSE](https://github.com/jessenich/docker-code-server-base/blob/master/LICENSE) for license information.

As with all Docker images, the built image likely also contains other software which may be under other licenses (such as software
from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant
licenses for all software contained within.
