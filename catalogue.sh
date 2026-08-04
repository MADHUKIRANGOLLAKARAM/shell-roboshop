#!/bin/bash
user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"

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

dnf module disable nodejs -y &>> $LOG_FILE
validate $? "disable default version..."

dnf module enable nodejs:20 -y
validate $? "Enableing latest version.."

dnf install nodejs -y &>> $LOG_FILE
validate $? "Installing nodejs"

