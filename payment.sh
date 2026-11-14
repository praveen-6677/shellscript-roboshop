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

dnf install python36 gcc python3-devel -y
validate "Failed to install python36, gcc and python3-devel"

useradd roboshop
validate "Failed to create roboshop user"

mkdir /app 
validate "Failed to create /app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip 
validate "Failed to download payment.zip"
cd /app 
validate "Failed to change directory"
unzip /tmp/payment.zip
validate "Failed to unzip payment.zip"
cd /app 
validate "Failed to change directory"
pip3 install -r requirements.txt            

cp payment.service /etc/systemd/system/payment.service
validate "Failed to copy payment.service file"
systemctl daemon-reload
validate "Failed to reload systemd daemon"
systemctl enable payment
validate "Failed to enable payment service"
systemctl start payment                             