# default arguments
AllowedCIDR="${AllowedCIDR:-0.0.0.0/0}"
InstanceType="${InstanceType:-t3a.micro}"
ProxyPort="${ProxyPort:-3128}"
VPNUser="${VPNUser:-vpn}"
VPNPassword="${VPNPassword:-123123123}"

# deploy stack
aws cloudformation deploy \
    --template-file ${TEMPLATE}.yaml \
    --stack-name ${StackName} \
    --parameter-overrides \
        "Environment=${StackName}" \
        "AllowedCIDR=${AllowedCIDR}" \
        "InstanceType=${InstanceType}" \
        "ProxyPort=${ProxyPort}" \
        "VPNUser=${VPNUser}" \
        "VPNPassword=${VPNPassword}" \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

# show stack outputs
echo
tput setaf 2 && tput bold && tput smul  # green, bold & underline
echo "Output:"
tput sgr0 && tput setaf 2  # green
#aws cloudformation describe-stacks --stack-name ${StackName} | jq '.Stacks[].Outputs[]'
aws cloudformation describe-stacks --stack-name ${StackName} | jq -r '.Stacks[].Outputs | sort_by(.OutputKey) | .[] | [.OutputKey, .OutputValue] | @tsv' | column -t
ProxyServer=$(aws cloudformation describe-stacks --stack-name ${StackName} | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="ProxyServer") | .OutputValue')
ProxyPort=$(aws cloudformation describe-stacks --stack-name ${StackName} | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="ProxyPort") | .OutputValue')
tput sgr0 # reset

# test the proxy
echo
echo -n "My IP without Proxy: "
curl --connect-timeout 5 https://ifconfig.co
echo -n "My IP with Proxy: "
curl --retry 7 --connect-timeout 5 --proxy ${ProxyServer}:${ProxyPort} https://ifconfig.co
echo

tput setaf 3 && tput bold  # yellow, bold
echo "Server: ${ProxyServer}"
tput sgr0 && tput setaf 3  # yellow
curl --connect-timeout 5 --proxy ${ProxyServer}:${ProxyPort} https://ifconfig.co/json 2>/dev/null | jq -r '"\(.asn_org) - \(.region_name), \(.country)"'
ping=$({ time nc -zw10 ${ProxyServer} ${ProxyPort} 2>/dev/null ; } 2>&1 | grep real | sed 's|.*\.0\{0,1\}\([0-9]*\)s|\1|')
echo -n "Ping: ${ping}ms"
tput sgr0 # reset
echo
