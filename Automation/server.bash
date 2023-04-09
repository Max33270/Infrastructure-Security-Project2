#!/bin/bash

# Update the package list and upgrade the system
sudo dnf update && sudo dnf upgrade

# Install necessary packages
sudo dnf install epel-release -y
sudo dnf install python39 -y
sudo dnf install python3-pip -y
sudo dnf install wget -y
pip3 install --upgrade pip -y
sudo pip3 install --timeout=3600 django==3.2.* Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \ django-pylibmc django-simple-captcha python3-ldap pycryptodome==3.12.0 
sudo dnf install -y git 
sudo dnf install -y mariadb
sudo dnf install -y mariadb-server
sudo dnf install -y mariadb-devel memcached libmemcached-awesome-devel
sudo dnf install -y gcc
sudo dnf install -y python3-devel
sudo -u seafile pip install mysqlclient --user 
sudo dnf install python3-devel python3-pip python3-setuptools python3-ldap python3-urllib3 python3-mysqldb -y
sudo dnf install -y gcc 
sudo dnf install -y nginx 
sudo dnf install -y zip 
sudo dnf install -y openssl 

# Create directory and user for Seafile
sudo mkdir /opt/seafile
cd /opt/seafile/
sudo adduser seafile
sudo chown -R seafile: /opt/seafile/

# Download and extract Seafile
cd
cd /tmp
wget https://s3.eu-central-1.amazonaws.com/download.seadrive.org/seafile-server_9.0.10_x86-64.tar.gz
sudo dnf install -y tar && tar xvzf seafile-server_9.0.10_x86-64.tar.gz && sudo dnf remove -y tar
cd seafile-server-9.0.10/
sudo mv seafile-server-9.0.10 /opt/seafile/ 

# Start Seafile and Seahub
sudo -u seafile bash seahub.sh start
sudo -u seafile sed -i "s/^Bind.*/Bind = '0.0.0.0:8080'/" /opt/seafile/conf/gunicorn.conf.py
sudo -u seafile ./seahub.sh restart

# Firewall 
sudo firewall-cmd --add-port=8080/tcp --permanent 
sudo firewall-cmd --reload

# Add ccnet.conf, seahub_settings.py, seafile.conf
cd
git clone "https://github.com/Max33270/Projet-Infra-SI"
if [ -f /opt/seafile/conf/ccnet.conf ]; then
    sudo rm /opt/seafile/conf/ccnet.conf
fi
sudo -u seafile cp Projet-Infra-SI/ccnet.conf /opt/seafile/conf/ccnet.conf
if [ -f /opt/seafile/seafile-server-latest/seahub/seahub/seahub_settings.py ]; then
    sudo rm /opt/seafile/seafile-server-latest/seahub/seahub/seahub_settings.py
fi
sudo -u seafile cp Projet-Infra-SI/seahub_settings.py /opt/seafile/seafile-server-latest/seahub/seahub/seahub_settings.py
if [ -f /opt/seafile/conf/seafile.conf ]; then
    sudo rm /opt/seafile/conf/seafile.conf
fi
sudo -u seafile cp Projet-Infra-SI/seafile.conf /opt/seafile/conf/seafile.conf


# Zip static files
cd
zip -r seafile_static /opt/seafile/seafile-server-latest/seahub/

# Firewall
sudo firewall-cmd --add-port=8000/tcp --permanent
sudo firewall-cmd --reload

# Linpeas
mkdir linpeas
cd linpeas/
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
sh linpeas.sh