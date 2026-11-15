
#!/bin/bash

ID=$(id -u)

if [ "$ID" -ne 0 ]; then
    echo "Run as root user"
    exit 1
else
    echo "You are root user"
fi

set -o pipefail

validate() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Import RabbitMQ signing keys
rpm --import https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
validate "Failed to import RabbitMQ signing key"

rpm --import https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
validate "Failed to import Erlang signing key"

rpm --import https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
validate "Failed to import RabbitMQ server signing key"

# Configure official RabbitMQ repositories
cat > /etc/yum.repos.d/rabbitmq.repo <<'EOF'
[modern-erlang]
name=modern-erlang
baseurl=https://yum1.rabbitmq.com/erlang/el/9/$basearch
        https://yum2.rabbitmq.com/erlang/el/9/$basearch
enabled=1
gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key

[modern-erlang-noarch]
name=modern-erlang-noarch
baseurl=https://yum1.rabbitmq.com/erlang/el/9/noarch
        https://yum2.rabbitmq.com/erlang/el/9/noarch
enabled=1
gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key

[rabbitmq-el9]
name=rabbitmq-el9
baseurl=https://yum2.rabbitmq.com/rabbitmq/el/9/$basearch
        https://yum1.rabbitmq.com/rabbitmq/el/9/$basearch
enabled=1
gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key

[rabbitmq-el9-noarch]
name=rabbitmq-el9-noarch
baseurl=https://yum2.rabbitmq.com/rabbitmq/el/9/noarch
        https://yum1.rabbitmq.com/rabbitmq/el/9/noarch
enabled=1
gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
EOF
validate "Failed to configure RabbitMQ repositories"

# Install RabbitMQ and Erlang
dnf clean all
dnf install erlang rabbitmq-server -y
validate "Failed to install RabbitMQ server"

# Enable RabbitMQ service
systemctl enable rabbitmq-server
validate "Failed to enable RabbitMQ service"

# Start RabbitMQ service
systemctl start rabbitmq-server
validate "Failed to start RabbitMQ service"

# Wait for RabbitMQ startup
rabbitmqctl await_startup
validate "RabbitMQ failed to start"

# Create RoboShop user if it does not exist
rabbitmqctl list_users | grep -q '^roboshop[[:space:]]' || rabbitmqctl add_user roboshop roboshop123
validate "Failed to add RabbitMQ user"

# Set user permissions
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate "Failed to set RabbitMQ permissions"

echo "RabbitMQ installation and configuration completed successfully"
