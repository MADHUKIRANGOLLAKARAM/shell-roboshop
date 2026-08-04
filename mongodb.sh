#!/bin/bash
user_id=$(id -u)

if [ $user_id -ne 0 ]; then
    echo "please enter root environment.."
    exit 1
fi


validate(){
    if [ $1 -ne 0 ]; then
        echo "$2 is failure..."
    else
        echo "$2 is success..."
    fi
}



dnf remove nginx -y
validate $? "installing mongo "