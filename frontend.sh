#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FOLDER_FILE_NAME="/var/log/Expense-shell"
FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%s-%H-%M-%S)
LOG_FILE_NAME="$FOLDER_FILE_NAME/$FILE_NAME-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 $R FAILURE $N"
        exit 1
    else
        echo -e "$2 $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then    
        echo "You must have sudo access to execute this script"
        exit 1
    fi
}

CHECK_ROOT

dnf install nginx -y
VALIDATE $? "Installing Nginx"
systemctl enable nginx
VALIDATE $? "Enabling Nginx"
systemctl start nginx
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Remove the default content that web server is serving"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading the code"

cd /usr/share/nginx/html/
VALIDATE $? "change directory "

unzip /tmp/frontend.zip
VALIDATE $? "Unzipping"

cp /home/ec2-user/Expense-shell/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx




