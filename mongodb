#!/bin/bash
user-id=$(id -u)
$LOGS_FOLDER="var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"

if [ $user-id -ne 0 ]; then
    echo "please enter root environment.."
    exit 1
fi


validate(){
    if [ $1 -ne 0 ]; then
        echo "$2 is failure..."
    else
        echo "$2 is success..."
    fi
}

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