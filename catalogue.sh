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

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip 
validate "Failed to download catalogue.zip"

cd /app 
validate "Failed to change directory"

unzip /tmp/catalogue.zip
validate "Failed to unzip catalogue.zip"

cd /app 
validate "Failed to change directory"

npm install 
validate "Failed to install Node.js dependencies"

cp /home/ec2-user/shellscript-roboshop/catalogue.service /etc/systemd/system
validate "Failed to copy catalogue.service file"

systemctl daemon-reload
validate "Failed to reload systemd daemon"

systemctl enable catalogue
validate "Failed to enable catalogue service"

systemctl start catalogue
validate "Failed to start catalogue service"
