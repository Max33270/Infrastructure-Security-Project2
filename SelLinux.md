# Installation 

```bash 
$ sudo dnf install selinux-policy selinux-policy-targeted
```

# Configuration 

```bash
$ sudo semanage fcontext -a -t httpd_sys_content_t "/var/www/html(/.*)?"

$ sudo restorecon -Rv /var/www/html

$ sudo sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config
```

# Restart 

Restart virtual machine or reboot the system to apply changes and apply selinux policy.
