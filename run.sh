#!/usr/bin/env bash

set -euo pipefail
ROOTDIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
export ROOTDIR
cd "$ROOTDIR"

source "./includes/utils.sh"

step "Full build & release flow for lambda-git"
info "Ensuring S3 buckets exist in all regions"
./includes/create_s3_buckets.sh
for ARCH in x86_64 arm64; do
    step "Starting execution for architecture ${ARCH}"
    ./includes/build.sh ${ARCH}
    ./includes/export.sh ${ARCH}
    ./includes/publish.sh ${ARCH}
    step "Summary"
    info "Lambda layers released successfully!"
done
