#!/bin/bash

# Update the package list and upgrade the system
sudo dnf update && sudo dnf upgrade

# Install necessary packages
sudo dnf install -y nginx
sudo dnf install -y zip
sudo dnf install -y openssl

# Start and Enable Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Add Ports to Firewall
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
sudo firewall-cmd --reload

# Create a directory for Seafile
sudo mkdir /var/www/
sudo mkdir /var/www/seafile
cd /var/www/ 
sudo chown -R audran : /var/www/seafile

scp audran@10.104.1.20:/home/audran/seafile_static.zip /var/www/seafile/
cd /var/www/seafile/
unzip seafile_static.zip

# Create a self-signed certificate
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout domain.key -out domain.crt
sudo mv domain.crt /etc/pki/tls/certs/
sudo mv domain.key /etc/pki/tls/private/

# Add seafile_proxy.conf to /etc/nginx/conf.d 
cd 
git clone "https://github.com/Max33270/Projet-Infra-SI"
mv Projet-Infra-SI/seafile_proxy.conf /etc/nginx/conf.d/

# Restart Nginx
sudo systemctl restart nginx

