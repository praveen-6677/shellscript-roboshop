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

dnf install maven -y
validate "Failed to install maven"

useradd roboshop
validate "Failed to create roboshop user"

mkdir /app
validate "Failed to create /app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip 
validate "Failed to download shipping.zip"

cd /app 
validate "Failed to change directory"

unzip /tmp/shipping.zip
validate "Failed to unzip shipping.zip"

cd /app 
validate "Failed to change directory"
mvn clean package 
validate "Failed to build shipping service"

mv target/shipping-1.0.jar shipping.jar 
validate "Failed to rename shipping jar file"

cp shipping.service /etc/systemd/system/shipping.service
validate "Failed to copy shipping.service file"
systemctl daemon-reload
validate "Failed to reload systemd daemon"
systemctl enable shipping
validate "Failed to enable shipping service"
systemctl start shipping                
validate "Failed to start shipping service"