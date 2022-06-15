#!/bin/bash

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

::grep-semver() {
    local input="$1";
    shift;

    # Match the major, minor, and patch versions
    local semver_regex="(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"

    # Allow pre-release versions to have a -, but not a .
    semver_regex="$semver_regex(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)"

    # Allow build metadata to have a +, but not a .
    semver_regex="$semver_regex\.?((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))"

    # Allow the regex to match the entire string
    semver_regex="$semver_regex?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?"

    # sanitize entire input string
    echo -n -e "${input//v/}\c" | grep -Eio "$semver_regex"
}

# shellcheck disable=SC2005,SC2312
::print-semver-vars() {
    local semver="$(::grep-semver "$1")";

    if [[ -z "$semver" ]]; then
        echo "Invalid semver: $1";
        exit 1;
    fi

    part1="$(echo -n "${semver}" | cut -d. -f1)";
    part2="$(echo -n "${semver}" | cut -d. -f2)";
    part3="$(echo -n "${semver}" | cut -d. -f3)";
    prerelease="$(echo -n "${semver}" | cut -d- -f2)";
    build="$(echo -n "${semver}" | cut -d+ -f2)";

    echo "SEMVER_FULL=$semver";
    echo "SEMVER_PART1=$part1";
    echo "SEMVER_PART2=$part2";
    echo "SEMVER_PART3=$part3";
    echo "SEMVER_PRERELASE=$prerelease";
    echo "SEMVER_BUILD_META=$build";
}

::login() {
    local registry="$1";
    local username="$2";
    local password="$3";

    registry="$(echo "$registry" | grep -Eio '^([a-zA-Z0-9]+([\.]){1})+.+$')";
    if [ -z "$registry" ]; then
        echo "ERR: No registry specified to ::login()." 1>&2;
        exit 1;
    fi

    if [ -z "$password" ]; then
        echo "ERR: Password is required to login to docker registry '$registry'." 1>&2;
        echo "";
        show_usage
        exit 1;
    fi

    local login_result="$(docker login "${registry}" --username "${username}" --password "${password}" 1>/dev/null 2>&1)";

    if [ "${login_result}" != true ] && [ "${login_result}" != 0 ]; then
        echo "ERR: Login to registry '${registry}' failed." 1>&2;
        echo "stdout: ${login_result}" 1>&2;
        show_usage
        exit 1;
    fi
}

::create-builderx() {
    docker buildx create \
        --name builder \
        --driver docker-container \
        --driver-opt image="${builder_image}" \
        --platform "${platforms}" \
        --use
}

::build() {
    local -r repository_root="../"
    eval '::print-semver-vars "${image_version//v/}"'

    # shellcheck disable=SC2154
    local -r tag1="$SEMVER_PART1.$SEMVERPART2.$SEMVER_PART3${SEMVER_PRERELEASE:+"-$SEMVER_PRERELEASE"}${SEMVER_BUILD_META:+"+$SEMVER_BUILD_META"}"
    local -r tag2="$SEMVER_PART1.$SEMVERPART2${SEMVER_PRERELEASE:+"-$SEMVER_PRERELEASE"}${SEMVER_BUILD_META:+"+$SEMVER_BUILD_META"}"
    local -r tag3="$SEMVER_PART1${SEMVER_PRERELEASE:+"-$SEMVER_PRERELEASE"}${SEMVER_BUILD_META:+"+$SEMVER_BUILD_META"}"

    docker buildx build \
        --file "$repository_root/Dockerfile" \
        "${tag1:+"--tag $dockerhub_library/$dockerhub_repository:$tag1"}" \
        "${tag1:+"--tag $ghcr_registry/$ghcr_library/$ghcr_repository:$tag1"}" \
        "${tag2:+"--tag $dockerhub_library/$dockerhub_repository:$tag2"}" \
        "${tag2:+"--tag $ghcr_registry/$ghcr_library/$ghcr_repository:$tag2"}" \
        "${tag3:+"--tag $dockerhub_registry/$dockerhub_repository:$tag3"}" \
        "${tag3:+"--tag $ghcr_registry/$ghcr_library/$ghcr_repository:$tag3"}" \
        "${latest:+"--tag $dockerhub_library/$dockerhub_repository:latest"}" \
        "${latest:+"--tag $ghcr_registry/$ghcr_library/$ghcr_repository:latest"}" \
        --build-arg "BASE_IMAGE_TAG=${version}" \
        --build-arg "SOURCE=$(git remote -v || true)" \
        --build-arg "VERSION=${tag1:-${tag2:-${tag3:-${latest:+latest}}}}" \
        --platform "${platforms}" \
        --push \
        --progress plain \
        "${repository_root}"
}

::help() {
    cat ./help.txt
}

::parse-args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | help | --help)
                ::help;
                exit 1;;

            -v | --version)
                version="$2";
                shift 2;;

            --dockerhub-login-endpoint)
                dockerhub_login_endpoint="$2";
                shift 2;;

            --dockerhub-username)
                dockerhub_username="$2";
                shift 2;;

            --dockerhub-password)
                dockerhub_password="$2";
                shift 2;;

            --dockerhub-password-stdin)
                read -rsp 'DockerHub Password or PAT' dockerhub_password;
                shift;;

            --dockerhub-library)
                dockerhub_library="$2";
                shift 2;;

            --dockerhub-repository)
                dockerhub_repository="$2";
                shift 2;;

            --ghcr-login-endpoint)
                ghcr_login_endpoint="$2";
                shift 2;;

            --ghcr-username)
                ghcr_username="$2";
                shift 2;;

            --ghcr-password)
                ghcr_password="$2";
                shift 2;;

            --ghcr-password-stdin)
                read -rsp 'GitHub Container Registry Password or PAT' ghcr_password
                shift;;

            --ghcr-library)
                ghcr_library="$2";
                shift 2;;

            --ghcr-repository)
                ghcr_repository="$2";
                shift 2;;

            --builder-image)
                builder_image="$2";
                shift 2;;

            -p | --platforms)
                platforms="$2"
                shift 2;;

            --latest)
                latest=true;
                shift;;

            --verbose)
                verbose=true;
                shift;;

            --)
                shift;
                break;;

             *)
                image_version="$1";
                shift;
                break;;
        esac
    done
}

::parse-args "$@"

# DockerHub Registry Settings
dockerhub_login_endpoint=${dockerhub_login_endpoint:-https://docker.io};
dockerhub_registry=${dockerhub_registry:-docker.io};
dockerhub_username=${dockerhub_username:-jessenich91};
dockerhub_library="jessenich91";
dockerhub_repository="alpine";

# GitHub Container Registry Settings
ghcr_login_endpoint="https://ghcr.io";
ghcr_registry="ghcr.io";
ghcr_username="jessenich";
ghcr_password= ;
ghcr_password_stdin=false;
ghcr_library="jessenich";
ghcr_repository="alpine";

builder_image="moby/buildkit:latest"
platforms="linux/amd64,linux/arm64/v8"

# Default to latest git tag
latest=true

# Image Build Arguments
base_image_version="3.14";
username="sysadm";

post_passthru=false;

test "${verbose}" && echo "${passthru[@]}"

## If we've reached this point without a valid --image-version, show usage info and exit with error code.
if [ -z "${image_version}" ]; then
    image_version="$(git describe --tags "$(git rev-list --tags --max-count=1)" | grep -Eo '([0-9]\.)+[0-9]+')"

    if [ -z "${image_version}" ]; then
        echo "Image version is required." 1>&2;
        ::help
        exit 1;
    fi
fi

::login "$dockerhub_login_endpoint" "$dockerhub_username" "$dockerhub_password"
::login "$ghcr_login_endpoint" "$ghcr_username" "$ghcr_password"
::create-builderx;
::build

exit 0;
