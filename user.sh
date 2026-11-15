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
dnf module disable nodejs -y

dnf install nodejs -y
validate "Failed to install Node.js"

id roboshop
if [ $? -ne 0 ] then
echo "useradd roboshop"
validate "user roboshop not created"
else 
 echo -e "user roboshop already exists skipping"
fi 
validate "Failed to create roboshop user"

mkdir -p /app
validate "Failed to create /app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip 
validate "Failed to download user.zip"

cd /app 
validate "Failed to change directory"
unzip /tmp/user.zip
validate "Failed to unzip user.zip"
cd /app 
validate "Failed to change directory"
npm install
validate "Failed to install Node.js dependencies"   

cp user.service /etc/systemd/system/user.service
validate "Failed to copy user.service file"
systemctl daemon-reload
validate "Failed to reload systemd daemon"
systemctl enable user
validate "Failed to enable user service"
systemctl start user        
