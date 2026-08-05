#!/bin/bash

user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
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

dnf install golang -y
validate $? "installing golang "

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "user created "
else
    echo "user already existing"
fi

mkdir -p /app
validate $? "creating app directory "

curl -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>> $LOG_FILE &>> $LOG_FILE
validate $? "downloading user files "

cd /app
validate $? "moving to app directory "

rm -rf /app/*
validate $? "remove everything "

unzip /tmp/dispatch.zip &>> $LOG_FILE &>> $LOG_FILE
validate $? "unzipping the code "

go mod init dispatch
go get 
go build
validate $? "change something "

cp $SCRIPT_DIR/dispatch.repo /etc/systemd/system/dispatch.service
validate $? "service settings "

systemctl daemon-reload
systemctl enable dispatch
systemctl start dispatch
validate $? "enable & start dispatch"