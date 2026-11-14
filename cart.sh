#!/bin/bash

ID = $(id -u)

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
validate "Failed to configure Node.js module"
dnf install nodejs -y
validate "Failed to install Node.js"
useradd roboshop
validate "Failed to create roboshop user"
mkdir /app
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

cp cart.service /etc/systemd/system/cart.service
validate "Failed to copy cart.service file"
systemctl daemon-reload
validate "Failed to reload systemd daemon"
systemctl enable cart
validate "Failed to enable cart service"
systemctl start cart
