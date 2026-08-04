#!/bin/bash
SG_ID="sg-0df39c725f035792e"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do 
    aws runn ec2-instances \
    --image-ids $AMI_ID \
    --security-group-ids $SG_ID \
    --instance-type t3.micro \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0],PrivateIpAddress' \
    --output text

done