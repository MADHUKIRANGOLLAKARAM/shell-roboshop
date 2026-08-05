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

dnf module disable nodejs -y
validate $? "disable default version "

dnf module enable nodejs:20 -y
validate $? "enable nodejs "

dnf install nodejs -y
validate $? "installing nodejs "

mkdir -p /app
validate $? "creating app directory "

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "creating user "


curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
validate $? "downloading user files "

cd /app
valiadte $? "moving to app directory "

unzip /tmp/user.zip
validate $? "unzipping the code "

npm install
validate $? "installing dependencies "


cp $SCRIPT_DIR/user.repo /etc/systemd/system/user.service
validate $? "changing system services "

systemctl daemon-reload
systemctl enable user
systemctl start user
validate $? "enable & start user  "
