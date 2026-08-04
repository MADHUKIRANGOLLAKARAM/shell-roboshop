#!/bin/bash
SG_ID="sg-0df39c725f035792e"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do 
    echo "creating $instance instance"
    aws ec2 run-instances \
    --image-id $AMI_ID \
    --security-group-ids $SG_ID \
    --instance-type t3.micro \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].PrivateIpAddress' \
    --output text
done


$LOGS_FOLDER="var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"

cp mongodb.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongodb repository.."

dnf install mongodb-org -y
validate $? "installing mongodb"

systemctl enable mongod
validate $? "enableing mongodb"

systemctl start mongod
validate $? "start mongodb "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "alowing all ports "

systemctl restart mongod
validate $? "reatarting mongodb"