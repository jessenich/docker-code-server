#!/usr/bin/env bash

# shellcheck shell=bash disable=SC2250,SC3060,SC2154,SC3010,SC2086

set -ex;

GH_RELEASES_JSON="$(curl -sL https://api.github.com/repos/cdr/code-server/releases/latest | jq .)";
CODE_VERSION="$(echo "$GH_RELEASES_JSON" | jq -r .tag_name)";
CODE_VERSION_NUMBER="${CODE_VERSION//v/}";
ASSET_NAME="code-server-$CODE_VERSION_NUMBER-linux-$CODE_ARCH.tar.gz";
JQ_EXPR=".assets | select(.name == \"$ASSET_NAME\") | .url"
ASSET_URL="$(echo $GH_RELEASES_JSON | jq "$JQ_EXPR")";

curl -fsSL "$ASSET_URL" -o /tmp/code-server-"$CODE_VERSION"-linux-amd64.tar.gz;
tar -xzf /tmp/code-server-"$CODE_VERSION"-linux-amd64.tar.gz -C /tmp;

if [[ -e /usr/local/lib/code-server ]]; then
  rm -rf /usr/local/lib/code-server;
fi

mkdir -p /usr/lib/code-server;
mv /tmp/code-server-"$CODE_VERSION_NUMBER"-linux-amd64 /usr/local/lib/code-server

if [[ ! -e /usr/local/lib/code-server/VERSION ]]; then
  echo "$CODE_VERSION" > /usr/local/lib/code-server/VERSION;
fi
