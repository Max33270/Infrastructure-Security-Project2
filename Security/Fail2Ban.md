# Installation 

```bash
$ sudo dnf install fail2ban -y
```

# Activation 

```bash
$ sudo systemctl start fail2ban.service
$ sudo systemctl enable fail2ban.service
```

# Configuration 

```bash
$ sudo vi /etc/fail2ban/jail.conf

# "bantime" is the number of seconds that a host is banned.
bantime  = 10m

# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime  = 1m

# "maxretry" is the number of failures before a host get banned.
maxretry = 3
``` 

# Restart 

```bash
$ sudo systemctl restart fail2ban
```




