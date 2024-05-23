#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d '.' -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Enter DB password:"
read -s db_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R FAILED $N"
    else
        echo -e "$2 .....$G SUCCESS $N"
    fi
}

if [ $USERID -eq 0 ]
then 
    echo -e "$G you are super user $N"
else
    echo -e "$R you must be super user to execute $N"
    exit 1
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Diasble nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enable nodejs20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Nodejs installation"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Expense user add"
else
    echo "expense user already exists"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Make directory /app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "download backend file"

rm -rf /app/* &>>$LOGFILE
VALIDATE $? "remove everything in /apps"

cd /app &>>$LOGFILE
VALIDATE $? "cd /app "

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "unzip"

cd /app &>>$LOGFILE
VALIDATE $? "cd /app "

npm install &>>$LOGFILE
VALIDATE $? "install dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copy backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "enable backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "MYSQL installation"

mysql -h db.sureshm.online -uroot -p < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "load schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restart backend"