#!/bin/bash

# Update the package list and upgrade the system
sudo dnf update && sudo dnf upgrade

# Install necessary packages
sudo dnf install epel-release -y
sudo dnf install python39 -y
sudo dnf install python3-pip -y
sudo dnf install wget -y
sudo dnf install -y tar && tar xvzf seafile-server_9.0.10_x86-64.tar.gz  && sudo dnf remove -y tar
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
cd seafile-server-9.0.10/
sudo mv seafile-server-9.0.10 /opt/seafile/

# Add the following lines to myfile.txt and save it
cat << EOF >> myfile.txt
10.104.1.20
8082
10.104.1.21
10.104.1.20
3306
seafile
azerty
ccnet_db
seafile_db
seahub_db
EOF

# Run Seafile setup script
cd /opt/seafile/
sudo -u seafile ./setup-seafile-mysql.sh < myfile.txt

# Start Seafile and Seahub
sudo -u seafile bash seahub.sh start
sudo -u seafile sed -i "s/^Bind.*/Bind = '0.0.0.0:8080'/" /opt/seafile/conf/gunicorn.conf.py
sudo -u seafile ./seahub.sh restart

# Firewall 
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# Edit ccnet.conf
sudo sed -i "/SERVICE_URL/d" /opt/seafile/conf/ccnet.conf
sudo sh -c "echo -e '[General]\nSERVICE_URL = http://seafile.linux.b2:8000\nSERVICE_URL = https://seafile.linux.b2:' >> /opt/seafile/conf/ccnet.conf"

# Edit seahub_settings.py
sudo sed -i "/SERVICE_URL/d" /opt/seafile/conf/seahub_settings.py
sudo sh -c "echo \"SERVICE_URL = 'http://10.104.1.20/'\" >> /opt/seafile/conf/seahub_settings.py"
sudo sh -c "echo \"FILE_SERVER_ROOT = 'https://seafile.linux.b2/seafhttp'\" >> /opt/seafile/conf/seahub_settings.py"

# Zip static files
cd
zip -r seafile_static /opt/seafile/seafile-server-latest/seahub/

# Nginx Install + Firewall
sudo systemctl start nginx
sudo systemctl enable nginx
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --reload

# Nginx Config
cd /etc/nginx/conf.d/

sudo nano seafile_proxy.conf <<EOL 
log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';

server {
    listen 80;
    server_name seafile.linux.b2;

    proxy_set_header X-Forwarded-For $remote_addr;

    location / {
         proxy_pass         http://10.104.1.20:8000;
         proxy_set_header   Host $host;
         proxy_set_header   X-Real-IP $remote_addr;
         proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host $server_name;
         proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;

         access_log      /var/log/nginx/seahub.access.log seafileformat;
         error_log       /var/log/nginx/seahub.error.log;
    }

    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://10.104.1.20:8082;
        client_max_body_size 0;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;

        send_timeout  36000s;

        access_log      /var/log/nginx/seafhttp.access.log seafileformat;
        error_log       /var/log/nginx/seafhttp.error.log;
    }

    location /media {
        root /var/www/opt/seafile/seafile-server-latest/seahub;
    }
}
EOL

# Firewall
sudo firewall-cmd --add-port=8000/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart nginx

# create directories
sudo mkdir -p /var/www/seafile
sudo chown -R $USER:$USER /var/www/seafile

# generate SSL certificate
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout domain.key -out domain.crt

sudo mv domain.crt /etc/pki/tls/certs/
sudo mv domain.key /etc/pki/tls/private/

# configure Nginx proxy
sudo tee /etc/nginx/conf.d/seafile_proxy.conf << EOL
log_format seafileformat '\$http_x_forwarded_for \$remote_addr [\$time_local] "\$request" \$status \$body_bytes_sent "\$http_referer" "\$http_user_agent" \$upstream_response_time';

server {
    listen 8000;
    server_name seafile.linux.b2;
    rewrite ^ https://\$http_host\$request_uri? permanent;
    server_tokens off;
}


server {
    server_name seafile.linux.b2;
    ssl on;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    ssl_certificate /etc/pki/tls/certs/domain.crt;
    ssl_certificate_key /etc/pki/tls/private/domain.key;
    server_tokens off;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    proxy_set_header X-Forwarded-For \$remote_addr;
    location / {
        proxy_pass         http://10.104.1.20:8000;
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host \$server_name;
        proxy_read_timeout  1200s;

     # used for view/edit office file via Office Online Server
        client_max_body_size 0;

        access_log      /var/log/nginx/seahub.access.log seafileformat;
        error_log       /var/log/nginx/seahub.error.log;
    }

# If you are using [FastCGI](http://en.wikipedia.org/wiki/FastCGI),
# which is not recommended, you should use the following config for location \`/\`.
#
#    location / {
#         fastcgi_pass    127.0.0.1:8000;
#         fastcgi_param   SCRIPT_FILENAME     \$document_root\$fastcgi_script_name;
#         fastcgi_param   PATH_INFO           \$fastcgi_script_name;
#
#         fastcgi_param  SERVER_PROTOCOL     $server_protocol;
#         fastcgi_param   QUERY_STRING        $query_string;
#         fastcgi_param   REQUEST_METHOD      $request_method;
#         fastcgi_param   CONTENT_TYPE        $content_type;
#         fastcgi_param   CONTENT_LENGTH      $content_length;
#         fastcgi_param  SERVER_ADDR         $server_addr;
#         fastcgi_param  SERVER_PORT         $server_port;
#         fastcgi_param  SERVER_NAME         $server_name;
#         fastcgi_param   REMOTE_ADDR         $remote_addr;
#        fastcgi_read_timeout 36000;
#
#         client_max_body_size 0;
#
#         access_log      /var/log/nginx/seahub.access.log;
#        error_log       /var/log/nginx/seahub.error.log;
#    }

    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://10.104.1.20:8082;
        client_max_body_size 0;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;

        send_timeout  36000s;

        access_log      /var/log/nginx/seafhttp.access.log seafileformat;
        error_log       /var/log/nginx/seafhttp.error.log;
    }
    location /media {
        root /var/www/seafile/opt/seafile/seafile-server-latest/seahub;
    }
}
EOL 

# Firewall
sudo systemctl restart nginx
sudo firewall-cmd --add-port=443/tcp --permanent
sudo firewall-cmd --reload

# Linpeas
mkdir linpeas
cd linpeas/
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
sh linpeas.sh
