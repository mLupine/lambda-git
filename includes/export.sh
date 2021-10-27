#!/usr/bin/env bash

set -euo pipefail
ROOTDIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
export ROOTDIR
cd "$ROOTDIR"

source "./includes/utils.sh"

ARCH="${1:-}"
if [[ "$ARCH" != "x86_64" && "$ARCH" != "arm64" ]]; then
    fatal 129 "Missing architecture argument"
fi

GIT_VERSION="$(cat ./git_version)"

step "Generating layer zip from ${ARCH} image"
filename="layer-git-${GIT_VERSION}-${ARCH}.zip"
if [[ -f "outputs/${filename}" ]]; then
    info "Skipping extraction, layer zip already exists (${filename})"
else
    info "Extracting /opt using a temporary Docker container"
    rm -rf .cache
    docker run --rm -v "${ROOTDIR}/.cache:/tmp/layer" lambda-git-build:${GIT_VERSION}-${ARCH} bash -c \
        "cd /opt && zip -yr /tmp/layer/layer.zip ." >docker-run.log 2>&1 \
        || fatal 133 "Unable to extract layer data. Refer to ${ROOTDIR}/docker-run.log for details."
    rm -f docker-run.log
    info "Moving extracted data into target directory"
    mkdir -p outputs
    mv .cache/layer.zip outputs/${filename} || fatal 134 "Unable to move layer zip to target directory"
    rm -rf .cache
fi
info "layer-git-${GIT_VERSION}-${ARCH}.zip created successfully"
