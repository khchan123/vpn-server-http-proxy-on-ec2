#/bin/bash
# Helper script to list all ec2 instances in all AWS regions

trap "echo Exited!; exit;" SIGINT SIGTERM

for region in `aws ec2 describe-regions --query "Regions[].{Name:RegionName}" --output text | sort`; do
    aws ec2 describe-instances --region $region \
        --output text \
        --query "Reservations[*].Instances[*].{
                Instance:InstanceId,
                Type:InstanceType,
                AZ:Placement.AvailabilityZone,
                Name:Tags[?Key==\`Name\`]|[0].Value,
                IP:PublicIpAddress,
                State:State.Name
            }" | \
        awk {'printf (" %-25s %-20s %-9s %-12s %-14s %-16s\n", $4, $3, $5, $6, $1, $2)'}
done
