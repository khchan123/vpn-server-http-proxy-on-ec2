#!/bin/bash
set -e

#AWS_PROFILE=
AWS_DEFAULT_REGION=eu-west-2

StackName="Tunnel-Server"
AllowedCIDR="$(curl https://ifconfig.co 2>/dev/null)/32"

TEMPLATE=tunnel-server
. deploy.${TEMPLATE}.cmd
