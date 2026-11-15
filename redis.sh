
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

# Install Valkey
dnf install valkey -y
validate "Failed to install Valkey"

# Configure bind address
sed -i 's/^bind .*/bind 0.0.0.0/' /etc/valkey/valkey.conf
validate "Failed to configure Valkey bind address"

# Enable Valkey service
systemctl enable valkey
validate "Failed to enable Valkey service"

# Start Valkey service
systemctl start valkey
validate "Failed to start Valkey service"

# Verify Valkey
valkey-cli ping
validate "Valkey is not responding"

echo "Redis-compatible Valkey installation completed successfully"
