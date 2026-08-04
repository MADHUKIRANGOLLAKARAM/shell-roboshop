#!/bin/bash

user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/s0.log"

if [ $user_id -ne 0 ]; then
    echo "you are not an root user"
    exit 1
fi
validate(){
    if [ $? -ne 0 ]; then
        echo "$2 is failure..." | tee -a $LOG_FILE
    else
        echo "$2 is success..." | tee -a $LOG_FILE
    fi
}

dnf module disable nginx -y &>> $LOG_FILE
validate $? "disableing default nginx version..."

dnf module enable nginx:1.24 -y &>> $LOG_FILE
validate $? "enableing latest nginx "

dnf install nginx -y &>> $LOG_FILE
validate $? "installing nodejs "

systemctl enable nginx &>> $LOG_FILE
validate $? "enable nginx"

systemctl start nginx &>> $LOG_FILE
validate $? "start nginx"