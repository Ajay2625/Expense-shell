#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FILE_FOLDER_NAME="/var/log/Expense-shell"
FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$FILE_FOLDER_NAME/$FILE_NAME-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILURE $Y"
        exit 1
    else
        echo -e "$2 is $G SUCCESS $Y"
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

echo "Script executing started at :$TIMESTAMP" &>>$LOG_FILE_NAME

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Mysql"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enable Mysqld"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Start Mysqld"

mysql -h mysql.ajayajay.com -u root -pExpenseApp1 -e 'show databases' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "mysql root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password"
else
    echo "MYsql root password Already Setup"
fi



