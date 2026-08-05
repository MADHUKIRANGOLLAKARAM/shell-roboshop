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

dnf install maven -y &>> $LOG_FILE
validate $? "installing maven "

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "user created "
else
    echo "user already existing"
fi

mkdir -p /app
validate $? "creating app directory "

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOG_FILE &>> $LOG_FILE
validate $? "downloading user files "

cd /app
validate $? "moving to app directory "

rm -rf /app/*
validate $? "remove everything "

unzip /tmp/shipping.zip &>> $LOG_FILE &>> $LOG_FILE
validate $? "unzipping the code "

mvn clean package &>> $LOG_FILE
validate $? "Install dependencies "

mv target/shipping-1.0.jar shipping.jar
validate $? "moving a file to app directory "


cp $SCRIPT_DIR/shipping.repo /etc/systemd/system/shipping.service &>> $LOG_FILE
validate $? "changing system services "

systemctl daemon-reload
systemctl enable shipping &>> $LOG_FILE
systemctl start shipping &>> $LOG_FILE
validate $? "enable & start shipping  "

dnf install mysql -y &>> $LOG_FILE
validate $? "installing mysql "

mysql -h 172.31.18.195 -uroot -pRoboshop@1 -e "show databases" | grep cities
if [ $? -ne 0 ]; then
    mysql -h 172.31.18.195 -uroot -pRoboshop@1 < /app/db/schema.sql &>> $LOG_FILE 
    mysql -h 172.31.18.195 -uroot -pRoboshop@1 < /app/db/schema.sql &>> $LOG_FILE 
    mysql -h 172.31.18.195 -uroot -pRoboshop@1 < /app/db/schema.sql &>> $LOG_FILE 
    validate $? "loading data to mysql "
else
    echo -e "data is already loaded..."
fi

systemctl enable shipping &>> $LOG_FILE
systemctl start shipping &>> $LOG_FILE
validate $? "enable & start shipping  "
