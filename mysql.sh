#!/bin/bash

ID=$(id -u)

if [ "$ID" -ne 0 ]; then
    echo "Run as root user"
    exit 1
else
    echo "you are root user"
fi
validate () {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

dnf module disable mysql -y 

cp /home/ec2-user/shellscript-roboshop/mysql.repo /etc/yum.repos.d/mysql.repo   
validate "Failed to copy mysql.repo file"
dnf install mysql-community-server -y
validate "Failed to install MySQL server"  

systemctl enable mysqld
systemctl start mysqld  
validate "Failed to start MySQL service"

mysql_secure_installation --set-root-pass RoboShop@1
validate "Failed to set MySQL root password"

mysql -uroot -pRoboShop@1
validate "Failed to login to MySQL server"
