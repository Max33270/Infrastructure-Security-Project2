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

## 2. Configuration

```bash
[audran@seafile ~]$ sudo mkdir /opt/seafile

[audran@seafile ~]$ cd /opt/seafile/

[audran@seafile seafile]$ sudo adduser seafile

[audran@seafile seafile]$ sudo chown -R seafile: /opt/seafile/
```