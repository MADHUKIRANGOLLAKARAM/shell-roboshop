#!/bin/bash

user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/s0.log"
SCRIPT_DIR=$PWD
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

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
validate $? "removing default content "

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
validate $? "Downloading data "

cd /usr/share/nginx/html &>> $LOG_FILE
validate $? "going to html directory "

unzip /tmp/frontend.zip &>> $LOG_FILE
validate $? "unzipping data "

cp $SCRIPT_DIR/frontend.conf /etc/nginx/nginx.conf
validate $? "copying conf data"

systemctl restart nginx
validate $? "restarting nginx "