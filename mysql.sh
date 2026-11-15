
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

# Disable default MySQL module
dnf module disable mysql -y

# Copy MySQL repository
cp /home/ec2-user/shellscript-roboshop/mysql.repo /etc/yum.repos.d/mysql.repo
validate "Failed to copy mysql.repo file"

# Install MySQL server
dnf install mysql-community-server -y
validate "Failed to install MySQL server"

# Enable and start MySQL
systemctl enable mysqld
validate "Failed to enable MySQL service"

systemctl start mysqld
validate "Failed to start MySQL service"

# Get temporary root password
TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

if [ -z "$TEMP_PASS" ]; then
    echo "Error: Temporary MySQL root password not found"
    exit 1
fi

# Set MySQL root password
mysql -uroot -p"$TEMP_PASS" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1'"
validate "Failed to set MySQL root password"

# Verify MySQL login
mysql -uroot -p'RoboShop@1' -e "SELECT VERSION();"
validate "Failed to login to MySQL server"

echo "MySQL installation and configuration completed successfully"
