#!/bin/bash

# Update the package list and upgrade the system
sudo dnf update -y && sudo dnf upgrade -y

# Install necessary packages
sudo dnf install -y mariadb
sudo dnf install -y mariadb-server
sudo dnf install -y mariadb-devel memcached libmemcached-awesome-devel

# Start MariaDB service and enable it to start at boot time 
sudo systemctl start mariadb 
sudo systemctl enable mariadb
sudo firewall-cmd --add-port=3306/tcp --permanent
sudo firewall-cmd --reload

# Secure MariaDB installation
sudo mysql_secure_installation

# Create database and user for Seafile
sudo mysql -u root -p
CREATE DATABASE IF NOT EXISTS `ccnet-db` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS `seafile-db` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS `seahub-db` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'seafile'@'10.104.1.20' IDENTIFIED BY 'seafile';
GRANT ALL PRIVILEGES ON `ccnet-db`.* TO 'seafile'@'10.104.1.20';
GRANT ALL PRIVILEGES ON `seafile-db`.* TO 'seafile'@'10.104.1.20';
GRANT ALL PRIVILEGES ON `seahub-db`.* TO 'seafile'@'10.104.1.20';
FLUSH PRIVILEGES;
EXIT;

# Restart mariadb service
sudo systemctl restart mariadb
