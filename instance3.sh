#!/bin/bash
SG_ID="sg-0df39c725f035792e"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do  
echo "creating $instance instance"
   Instance_id=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --security-group-ids $SG_ID \
    --instance-type t3.micro \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

if [ "$instance" == "frontend" ]; then
  IP=$( aws ec2 describe-instances \
    --instance-ids $Instance_id \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text)
else
    IP=$(
        aws ec2 describe-instances \
        --instance-ids $Instance_id \
        --query 'Reservations[].Instances[].PrivateIpAddress' \
        --output text
    )
fi

echo "$instance ip is :$IP"
done