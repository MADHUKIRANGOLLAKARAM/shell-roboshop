#!/bin/bash
user-id=$(id -u)

if [ $user-id -ne 0 ]; then
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



dnf install mongodb-org -y
valiadte $? "installing mongo "