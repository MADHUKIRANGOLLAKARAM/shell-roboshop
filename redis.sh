#!/bin/bash
user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

if [ $user_id -ne 0 ]; then
    echo "please enter root user environment..."  | tee -a $LOG_FILE
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
        echo "$2 is failure.."  | tee -a $LOG_FILE
    else
        echo "$2 is success..."  | tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>> $LOG_FILE
validate $? "disable default version "

dnf module enable redis:7 -y &>> $LOG_FILE
validate $? "enable new version"

dnf install redis -y
validate $? "installing redis "

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/protected-mode.*/protected-mode no/' /etc/redis/redis.conf
validate $? "allowing remote ports"

systemctl enable redis
validate $? "enabling redis "

systemctl start redis
validate $? "starting redis "