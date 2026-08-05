#!/bin/bash
user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD


if [ $user_id -ne 0 ]; then
    echo "please enter root environment.."
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
        echo "$2 is failure..." | tee -a $LOG_FILE
    else
        echo "$2 is success..." | tee -a $LOG_FILE
    fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "copying repo "

dnf install rabbitmq-server -y
validate $? "installing rabbitmq "

systemctl enable rabbitmq-server
systemctl start rabbitmq-server

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? "add user and give permisiions"