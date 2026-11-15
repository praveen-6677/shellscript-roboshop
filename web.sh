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

dnf install nginx -y 
validate "Failed to install nginx"  

systemctl enable nginx 
systemctl start nginx 

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip 
validate "failed to unzip"

cd /usr/share/nginx/html
validate "Failed to change directory to /usr/share/nginx/html"

unzip /tmp/frontend.zip
validate "Failed to unzip frontend.zip"

cp /home/ec2-user/shellscript-roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf
validate "Failed to copy roboshop.conf file"

systemctl restart nginx
validate "Failed to restart nginx service"
