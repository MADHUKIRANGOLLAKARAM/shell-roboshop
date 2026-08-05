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

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
validate $? "installing python "

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "user created "
else
    echo "user already existing"
fi

mkdir -p /app
validate $? "creating app directory "

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOG_FILE
validate $? "downloading user files "

cd /app
validate $? "moving to app directory "

unzip /tmp/payment.zip &>> $LOG_FILE
validate $? "unzipping the code "

pip3 install -r requirements.txt &>> $LOG_FILE
validate $? "Installing dependencies"

cp $SCRIPT_DIR/payment.repo /etc/systemd/system/payment.service &>> $LOG_FILE
validate $? "copying system services "

systemctl daemon-reload
systemctl enable payment &>> $LOG_FILE
systemctl start payment &>> $LOG_FILE
validate $? "enable & start payment"