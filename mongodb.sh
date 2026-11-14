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

cp mongod.repo /etc/yum.repos.d/mongo.repo
validate "Failed to copy MongoDB repository file"
dnf install mongodb-org -y 
validate "Failed to install MongoDB"
systemctl enable mongod
validate "Failed to enable MongoDB service" 
systemctl start mongod 
validate "Failed to start MongoDB service" 
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate "Failed to update MongoDB configuration"
systemctl restart mongod
validate "Failed to restart MongoDB service"
