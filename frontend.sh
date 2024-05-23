#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d '.' -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "install nginx "

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "start nginx "

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "install dependencies"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "copy backend service"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "move to html"

unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "unzip frontend"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copy backend service"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restart nginx"
