# Projet Infra/SI - Latorre Audran & Doublait Maxim B2B

## 🖥 Seafile Server 

### 1. Installations

```bash 
$ sudo dnf update && sudo dnf upgrade

$ sudo dnf -y install epel-release

$ sudo dnf install python39 -y

$ sudo dnf install python3-pip

$ sudo dnf install -y wget

$ sudo dnf install -y tar && tar xvzf seafile-server_9.0.10_x86-64.tar.gz  && sudo dnf remove -y tar

$ pip3 install --upgrade pip

$ sudo pip3 install --timeout=3600 django==3.2.* Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \ django-pylibmc django-simple-captcha python3-ldap pycryptodome==3.12.0 cffi==1.14.0 lxml

$ sudo dnf install -y zip

$ sudo dnf install netdata -y

$ sudo dnf install stress-ng
```

### 2. Configuration

```bash
$ sudo mkdir /opt/seafile

$ cd /opt/seafile/

$ sudo adduser seafile

$ sudo chown -R seafile: /opt/seafile/
```

```bash
$ cd 

$ cd /tmp

$ wget https://s3.eu-central-1.amazonaws.com/download.seadrive.org/seafile-server_9.0.10_x86-64.tar.gz

$ cd seafile-server-9.0.10/

$ cat seafile-server_9.0.10_x86-64.tar.gz | md5sum

$ sudo mv seafile-server-9.0.10 /opt/seafile/

$ cd /opt/seafile/ 
```

```bash
$ sudo -u seafile ./setup-seafile-mysql.sh

What is the ip or domain of the server? 
10.104.1.20

Which port do you want to use for the seafile fileserver? 
[ default "8082" ]

What is the host of mysql server? 
[ default "localhost" ] 10.104.1.21

From which hosts could the mysql access be used? 
[ default "%" ] 10.104.1.20

What is the port of mysql server? 
[ default "3306" ]

Which mysql user to use for seafile? 
[ mysql user for seafile ] seafile

What is the password for mysql user "seafile"? 
[ password for seafile ]

verifying password of user seafile... done 

Enter the existing database name for ccnet: 
[ ccnet database ] ccnet_db

verifying user "seafile" access to database "ccnet_db"... done

Enter the existing database name for seafile: 
[ seafile database ] seafile_db

verifying user "seafile" access to database "seafile_db"... done

Enter the existing database name for seahub: 
[ seahub database ] seahub_db

verifying user "seafile" access to database "seahub_db"... done

--------------------------------
This is your configuration
--------------------------------

    server name:        seafile
    server ip/domain:   10.104.1.20

    seafile data dir:   /opt/seafile/seafile-data
    fileserver port:    8082
```

```bash
Press Enter to continue, or Ctrl-C to abort
--------------------------------
Generating ccnet configuration ...

Generating seafile configuration ...

done
Generating seahub configuration ...

--------------------------------
Now creating ccnet database tables ...

--------------------------------
--------------------------------
Now creating seafile database tables ...

--------------------------------
--------------------------------
Now creating seahub database tables ...

--------------------------------

creating seafile-server-latest symbolic link ... done



-----------------------------------------------------------------
Your seafile server configuration has been finished successfully.
-----------------------------------------------------------------

run seafile server:   ./seafile.sh { start | stop | restart }
run seahub  server:   ./seahub.sh  { start <port> | stop | 
restart <port> } 

-----------------------------------------------------------------
If you are behind a firewall, remember to allow input/output of these tcp ports:
-----------------------------------------------------------------

port of seafile server:   8082
port of seahub:           8000

When problems occur, Refer to

        https://download.seafile.com/published/seafile-manual/home.md

for information.
```

```bash
$ sudo -u seafile bash seahub.sh start

LC_ALL is not set in ENV, set to en_US.UTF-8
Starting seahub at port 8000 ...

Seahub is started

Done.
```

```bash
$ sudo -u seafile nano /opt/seafile/conf/gunicorn.conf.py

Bind = '0.0.0.0:8080'

$ sudo -u seafile ./seahub.sh restart

$ sudo firewall-cmd --add-port=8080/tcp --permanent
$ sudo firewall-cmd --reload
```

```bash
$ sudo nano /opt/seafile/conf/ccnet.conf

# Add the following lines : 
[General]
SERVICE_URL = http://seafile.linux.b2:8000
SERVICE_URL = https://seafile.linux.b2:

$ sudo nano /opt/seafile/conf/seahub_settings.py

# -*- coding: utf-8 -*-
SECRET_KEY = "b'c8t+tm!0+9vid5=t+b=&9qm63fntffy!djqm@0tj5j!t%((!&g'"
SERVICE_URL = "http://10.104.1.20/"
(Ajouter cette ligne)
FILE_SERVER_ROOT = 'https://seafile.linux.b2/seafhttp'
```

```bash
$ cd
zip -r seafile_static /opt/seafile/seafile-server-latest/seahub/
```

```
$ mkdir linpeas
$ cd linpeas/
$ curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
$ sh linpeas.sh
```

## 🖥 Seafile Database 

### 1. Installations

```bash
$ sudo dnf install -y mariadb-server

$ sudo dnf install -y mariadb-devel memcached libmemcached-awesome-devel

$ sudo dnf install -y gcc

$ sudo dnf install -y python3-devel

$ sudo -u seafile pip install mysqlclient --user
```

### 2. Configuration

```bash
$ sudo systemctl start mariadb

$ sudo systemctl enable mariadb

$ sudo firewall-cmd --add-port=3306/tcp --permanent

$ sudo firewall-cmd --reload
```

```bash
$ sudo mysql_secure_installation

$ mysql -u root -p

MariaDB [(none)]> create database `ccnet_db` character set = 'utf8';

MariaDB [(none)]> create database `seafile_db` character set = 'utf8';

MariaDB [(none)]> create database `seahub_db` character set = 'utf8';

MariaDB [(none)]> create user 'seafile'@'10.104.1.20' identified by 'seafile';

MariaDB [(none)]> GRANT ALL PRIVILEGES ON `ccnet_db`.* to `seafile`@10.104.1.20;

MariaDB [(none)]> GRANT ALL PRIVILEGES ON `seafile_db`.* to `seafile`@10.104.1.20;

MariaDB [(none)]> GRANT ALL PRIVILEGES ON `seahub_db`.* to `seafile`@10.104.1.20;

MariaDB [(none)]> flush privileges;

MariaDB [(none)]> exit
```

## 🖥 Seafile Reverse Proxy 

### 1. Installations

```bash
$ sudo dnf update -y

$ sudo dnf install -y nginx

$ sudo dnf install -y zip 

$ sudo dnf -y install openssl
```

### 2. Configuration

```bash
$ sudo systemctl start nginx
$ sudo systemctl enable nginx
$ sudo firewall-cmd --add-port=80/tcp --permanent
$ sudo firewall-cmd --reload
```

```bash
$ cd /etc/nginx/conf.d/

$ sudo nano seafile_proxy.conf

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

# If you are using [FastCGI](http://en.wikipedia.org/wiki/FastCGI),
# which is not recommended, you should use the following config for location `/`.
#
#    location / {
#         fastcgi_pass    127.0.0.1:8000;
#         fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
#         fastcgi_param   PATH_INFO           $fastcgi_script_name;
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
        root /var/www/opt/seafile/seafile-server-latest/seahub;
    }
}
```

```bash
$ sudo firewall-cmd --add-port=8000/tcp --permanent
$ sudo firewall-cmd --reload
$ sudo systemctl restart nginx
```

```
$ sudo mkdir /var/www
$ sudo mkdir /var/www/seafile
$ cd /var/www/
$ sudo chown -R audran: seafile/
$ cd 
$ openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout domain.key -out domain.crt

$ sudo mv domain.crt /etc/pki/tls/certs/
$ sudo mv domain.key /etc/pki/tls/private/
$ cd /etc/nginx/conf.d/
$ sudo nano seafile_proxy.conf

log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';

server {
    listen 8000;
    server_name seafile.linux.b2;
    rewrite ^ https://$http_host$request_uri? permanent;
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

# If you are using [FastCGI](http://en.wikipedia.org/wiki/FastCGI),
# which is not recommended, you should use the following config for location `/`.
#
#    location / {
#         fastcgi_pass    127.0.0.1:8000;
#         fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
#         fastcgi_param   PATH_INFO           $fastcgi_script_name;
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
```
```bash
$ sudo systemctl restart nginx
$ sudo firewall-cmd --add-port=443/tcp --permanent
$ sudo firewall-cmd --reload
```
