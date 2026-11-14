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
dnf module disable redis -y
dnf module enable redis:6 -y
validate "Failed to configure Redis module"
dnf install redis -y
validate "Failed to install Redis"  
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
validate "Failed to configure Redis bind address"
sed -i 's/127.0.0.0/0.0.0.0/' /etc/redis/redis.conf
validate "Failed to configure Redis bind address"
systemctl enable redis
validate "Failed to enable Redis service"
systemctl start redis
validate "Failed to start Redis service"