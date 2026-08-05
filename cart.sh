user_id=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

if [ $user_id -ne 0 ]; then
    echo "please enter root cart environment..."  | tee -a $LOG_FILE
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
validate $? "disable default version "

dnf module enable nodejs:20 -y &>> $LOG_FILE
validate $? "enable nodejs "

dnf install nodejs -y &>> $LOG_FILE
validate $? "installing nodejs "

mkdir -p /app
validate $? "creating app directory "

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    cartadd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    validate $? "creating user "
else
    echo "user already exist"
fi

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOG_FILE
validate $? "downloading cart files "

cd /app
valiadte $? "moving to app directory "

unzip /tmp/cart.zip &>> $LOG_FILE
validate $? "unzipping the code "

npm install &>> $LOG_FILE
validate $? "installing dependencies "


cp $SCRIPT_DIR/cart.repo /etc/systemd/system/cart.service
validate $? "changing system services "

systemctl daemon-reload
systemctl enable cart &>> $LOG_FILE
systemctl start cart &>> $LOG_FILE
validate $? "enable & start cart  "
