#!/usr/bin/env bash
set -euo pipefail

repo="https://github.com/Haoming02/sd-webui-forge-classic.git"

tag=$(
  git ls-remote --tags "$repo" \
    | awk '{ print $2 }' \
    | sed -E 's#^refs/tags/##; s#\^\{\}$##' \
    | grep -E '^[0-9]+(\.[0-9]+)*$' \
    | sort -V \
    | tail -n 1
)

if [ -z "$tag" ]; then
  echo "Unable to resolve latest Forge Neo numeric tag" >&2
  exit 1
fi

printf '%s\n' "$tag"

