# Projet Infra/SI - Latorre Audran & Doublait Maxim B2B

## 1. Installations

```bash 
$ sudo dnf update && sudo dnf upgrade

$ sudo dnf -y install epel-release

$ sudo dnf install python39 -y

$ sudo dnf install python3-pip

$ pip3 install --upgrade pip

$ sudo dnf install -y mariadb-devel memcached libmemcached-awesome-devel

$ sudo dnf install -y wget

[audran@seafile ~]$ sudo pip3 install --timeout=3600 django==3.2.* Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \ django-pylibmc django-simple-captcha python3-ldap pycryptodome==3.12.0 cffi==1.14.0 lxml

[audran@seafile ~]$ sudo dnf install -y mariadb-server
```

## 2. Configuration Seafile

```bash
[audran@seafile ~]$ sudo mkdir /opt/seafile

[audran@seafile ~]$ cd /opt/seafile/

[audran@seafile seafile]$ sudo adduser seafile

[audran@seafile seafile]$ sudo chown -R seafile: /opt/seafile/
```

```bash
$ cd 

$ cd /tmp

$ wget https://s3.eu-central-1.amazonaws.com/download.seadrive.org/seafile-server_9.0.10_x86-64.tar.gz

$ sudo dnf install -y tar && tar xvzf seafile-server_9.0.10_x86-64.tar.gz  && sudo dnf remove -y tar

$ cd seafile-server-9.0.10/

$ cat seafile-server_9.0.10_x86-64.tar.gz | md5sum

$ sudo mv seafile-server-9.0.10 /opt/seafile/

$ cd /opt/seafile/ 
```

```bash
[audran@seafile seafile]$ sudo systemctl start mariadb

[audran@seafile seafile]$ sudo systemctl enable mariadb

[audran@seafile ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent

[audran@seafile ~]$ sudo firewall-cmd --reload

```


## 3. Other 
    
```bash
cffi==1.14.0 ??????????
```