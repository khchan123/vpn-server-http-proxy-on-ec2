#!/bin/bash
set -e

#export AWS_PROFILE=
AWS_DEFAULT_REGION=us-west-2

StackName="Tunnel-Server"
AllowedCIDR="$(curl https://ifconfig.co 2>/dev/null)/32"

TEMPLATE=tunnel-server
. deploy.${TEMPLATE}.cmd
