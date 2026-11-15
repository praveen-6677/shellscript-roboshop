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
dnf module enable nodejs:18 -y
dnf install nodejs -y
validate "Failed to install Node.js"
id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    validate "roboshop user created"
else
    echo -e "roboshop user already exist SKIPPING"
fi
mkdir -p /app
validate "Failed to create /app directory"
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip 
validate "Failed to download cart.zip"
cd /app 
validate "Failed to change directory"
unzip /tmp/cart.zip
validate "Failed to unzip cart.zip"
cd /app 
validate "Failed to change directory"
npm install 
validate "Failed to install Node.js dependencies"  

cp /home/ec2-user/shellscript-roboshop/cart.service /etc/systemd/system/cart.service
validate "Failed to copy cart.service file"
systemctl daemon-reload
validate "Failed to reload systemd daemon"
systemctl enable cart
validate "Failed to enable cart service"
systemctl start cart
