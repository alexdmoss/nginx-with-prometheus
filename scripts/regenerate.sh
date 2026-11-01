#!/usr/bin/env bash
#
# Vendors nginx-lua-prometheus into conf/lua/ at the given release tag.
# Renovate bumps the version below and runs this (postUpgradeTasks), so the
# MR carries the new files; the image tests then exercise them.
#
# Usage: ./scripts/regenerate.sh [version]

set -euo pipefail

# renovate: datasource=github-tags depName=knyar/nginx-lua-prometheus
LUA_PROMETHEUS_VERSION=0.20260912

VERSION="${1:-${LUA_PROMETHEUS_VERSION}}"
BASE_URL="https://raw.githubusercontent.com/knyar/nginx-lua-prometheus/${VERSION}"
DEST="$(cd "$(dirname "$0")/.." && pwd)/conf/lua"
FILES=(prometheus.lua prometheus_keys.lua prometheus_resty_counter.lua)

mkdir -p "${DEST}"
for file in "${FILES[@]}"; do
  echo "-> [INFO] ${file} @ ${VERSION}"
  curl -fsSL "${BASE_URL}/${file}" -o "${DEST}/${file}.tmp"
  mv "${DEST}/${file}.tmp" "${DEST}/${file}"
done

# Keep the default version in step when called with an explicit one
sed -i "s/^LUA_PROMETHEUS_VERSION=.*/LUA_PROMETHEUS_VERSION=${VERSION}/" "$0"
