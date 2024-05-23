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

dnf install mysql-server -y &>> $LOGFILE
VALIDATE $? "MYSQL installation"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling mysql"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "starting mysql"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

mysql -h db.sureshm.online -uroot -p -e 'show databases;' &>> $LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass $db_root_password &>> $LOGFILE
    VALIDATE $? "setting root password"
else
    echo -e "mysql root password already setup $Y SKIPPING... $N"
fi

