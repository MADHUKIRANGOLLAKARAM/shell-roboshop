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

dnf module disable nodejs -y &>> $LOG_FILE
validate $? "disable default version..."

dnf module enable nodejs:20 -y &>> $LOG_FILE
validate $? "Enableing latest version.."

dnf install nodejs -y &>> $LOG_FILE
validate $? "Installing nodejs"

mkdir -p /app
validate $? "creating app directory "

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating roboshop user  "
else
 echo "roboshop user is already exist skipping."
fi

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
validate $? "downloading catalogue "

cd /app
validate $? "moving to app directory "

rm -rf /app/* &>> $LOG_FILE
validate $? "removing everything "

unzip /tmp/catalogue.zip
validate $? "unzipping the code"

npm install &>> $LOG_FILE
validate $? "Installing Dependencies "

cp $SCRIPT_DIR/catalogue.repo /etc/systemd/system/catalogue.service
validate $? "created systemctl services "

systemctl daemon-reload &>> $LOG_FILE
systemctl enable catalogue &>> $LOG_FILE
systemctl start catalogue &>> $LOG_FILE
validate $? "start&enableing the catalogue "

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-mongosh -y &>> $LOG_FILE
validate $? "Installing mongodb client"

INDEX=$(mongosh --host 172.31.17.24 --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -lt 0 ]; then
    mongosh --host 172.31.17.24 </app/db/master-data.js &>> $LOG_FILE
    validate $? "Loading products"
else
    echo "products already loaded skipping now..."
fi

systemctl restart catalogue
validate $? "restarting catalogue "