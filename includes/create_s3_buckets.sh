#!/usr/bin/env bash

set -euo pipefail
ROOTDIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
export ROOTDIR
cd "$ROOTDIR"

BUCKET_PREFIX="lupin-lambda-git-"

source "./includes/utils.sh"
source "./includes/aws_utils.sh"

step "Ensuring S3 buckets exist in all available regions"
REGIONS="$(list_aws_regions)" || fatal 131 "Unable to determine a list of AWS regions"
REGION_COUNT=$(echo $REGIONS | wc -w | xargs)
info "Found ${REGION_COUNT} regions"

for region in ${REGIONS}; do
    info "Checking ${region}…"
    bucket_name="${BUCKET_PREFIX}${region}"
    aws s3 --region "$region" ls "s3://${bucket_name}" >/dev/null 2>&1 || (
        warn "Bucket ${bucket_name} does not exist, creating"
        aws s3 --region "$region" mb "s3://${bucket_name}" >aws_s3_mb.log 2>&1 || fatal 132 "Unable to create bucket. Refer to ${ROOTDIR}/aws_s3_mb.log for details."
        rm aws_s3_mb.log
        info "Bucket created successfully"
    )
done
