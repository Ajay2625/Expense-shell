#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FOLDER_FILE_NAME="/var/log/Expense-shell"
FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$FOLDER_FILE_NAME/$FILE_NAME-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 $R FAILURE $N"
    else 
        echo -e "$2 $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "you must have sudo access to execute this script"
        exit 1
    fi
}

CHECK_ROOT

echo "Script started executing at : $TIMESTAMP" &>>$LOG_FILE_NAME

dnf module disable  nodejs -y
VALIDATE $? "Disabling nodejs older version"
dnf module enable  nodejs:20 -y
VALIDATE $? "Enabling nodejs:20 version"
dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Nodejs installing"
useradd expense
VALIDATE $? "User Added"
mkdir /app
VALIDATE $? "/app folder created"
curl curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading the code zip file into /tmp folder"
cd /app/
VALIDATE $? "change directory to /app/ folder"
unzip /tmp/backend.zip
VALIDATE $? "unzipping backend"
npm install
VALIDATE $? "NPM install command"

cp /home/ec2-user/Expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql client"

mysql -h mysql.ajayajay.com -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "setting up transaction schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon Reloading"

systemcl enable backend
VALIDATE $? "enabling backend"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting backend"




