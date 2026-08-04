#!/bin/bash

user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGSFOLDER/s0.log"

if [ $user_id -ne 0 ]; then
    echo "ypu are not an user"
    exit 1

validate(){
    if [ $! -ne 0 ]; then
        echo "$2 is failure..." | tee -a $LOG_FILE
    else
        echo "$2 is success..." | tee -a $LOG_FILE
    fi
}

dnf module disable nginx -y
validate $? "disableing default nginx version..."

dnf module enable nginx:1.24 -y
validate $? "enableing latest nginx "

dnf install nginx -y
validate $? "installing nodejs "

systemctl enable nginx
systemctl start nginx
validate $? "enable & start nginx"