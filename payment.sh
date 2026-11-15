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

dnf install python36 gcc python3-devel -y
validate "Failed to install python36, gcc and python3-devel"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    validate "roboshop user created"
else
    echo -e "roboshop user already exist SKIPPING"
fi
mkdir -p /app
validate "app directory not created"
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip 
validate "Failed to download payment.zip"
cd /app 
validate "Failed to change directory"
unzip /tmp/payment.zip
validate "Failed to unzip payment.zip"
cd /app 
validate "Failed to change directory"
pip3 install -r requirements.txt            

cp /home/ec2-user/shellscript-roboshop/payment.service /etc/systemd/system/payment.service
validate "Failed to copy payment.service file"
systemctl daemon-reload
validate "Failed to reload systemd daemon"
systemctl enable payment
validate "Failed to enable payment service"
systemctl start payment                             
