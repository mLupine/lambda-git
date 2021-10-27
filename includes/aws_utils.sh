#!/usr/bin/env bash

set -euo pipefail

function list_aws_regions() {
    aws ssm get-parameters-by-path \
        --path /aws/service/global-infrastructure/services/lambda/regions \
        --query 'Parameters[].Value' \
        --output text | tr '[:blank:]' '\n' | grep -v -e ^cn- -e ^us-gov- -e ^me- -e ^af- -e ^ap-east-1 -e ^eu-south-1 | sort -r
}
