
#!/bin/bash

ID=$(id -u)

if [ "$ID" -ne 0 ]; then
    echo "Run as root user"
    exit 1
else
    echo "You are root user"
fi

validate() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# MongoDB private IP
MONGODB_HOST="172.31.35.167"

dnf install nodejs unzip curl -y
validate "Failed to install dependencies"

id roboshop
if [ $? -ne 0 ]; then
    useradd roboshop
    validate "Failed to create roboshop user"
else
    echo "Roboshop user already exists SKIPPING"
fi

mkdir -p /app
validate "Failed to create /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
validate "Failed to download catalogue.zip"

cd /app
validate "Failed to change directory"

unzip -o /tmp/catalogue.zip
validate "Failed to unzip catalogue.zip"

npm install
validate "Failed to install Node.js dependencies"

cp /home/ec2-user/shellscript-roboshop/catalogue.service /etc/systemd/system/
validate "Failed to copy catalogue.service"

# Install MongoDB Shell
cp /home/ec2-user/shellscript-roboshop/mongod.repo /etc/yum.repos.d/mongod.repo
validate "Failed to copy MongoDB repository"

dnf install mongodb-mongosh -y
validate "Installing MongoDB Shell failed"

# Check MongoDB connectivity
mongosh --host "$MONGODB_HOST" --eval "db.adminCommand('ping')"
validate "MongoDB connection failed"

# Load product catalogue
mongosh "mongodb://${MONGODB_HOST}:27017/catalogue" \
    --file /app/schema/catalogue.js

validate "Loading catalogue data into MongoDB failed"

# Start Catalogue service
systemctl daemon-reload
validate "Failed to reload systemd daemon"

systemctl enable catalogue
validate "Failed to enable catalogue service"

systemctl restart catalogue
validate "Failed to start catalogue service"

echo "Catalogue setup completed successfully"
