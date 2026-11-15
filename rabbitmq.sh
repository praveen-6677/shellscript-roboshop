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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
validate "Failed to configure Erlang repository"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
validate "Failed to configure RabbitMQ repository"

dnf install rabbitmq-server -y 
validate "Failed to install RabbitMQ server"

systemctl enable rabbitmq-server 
validate "Failed to enable RabbitMQ service"

systemctl start rabbitmq-server 
validate "Failed to start RabbitMQ service"

rabbitmqctl add_user roboshop roboshop123
validate "Failed to add RabbitMQ user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate "Failed to set RabbitMQ permissions"           
