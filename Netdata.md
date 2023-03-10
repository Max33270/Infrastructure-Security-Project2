# Installation 

```bash
$ sudo dnf install epel-release -y

$ sudo wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh

$ sudo dnf install netdata -y

$ sudo dnf install stress-ng
```

# Activation 

```bash
$ sudo systemctl start netdata
$ sudo systemctl enable netdata
```

# Firewall 

```bash
$ sudo ss -alnpt
LISTEN         0               4096                           0.0.0.0:19999                        0.0.0.0:*
users:(("netdata",pid=4096,fd=49))

$ sudo firewall-cmd --add-port=19999/tcp --permanent
$ sudo firewall-cmd --reload
```

# Verification : Netdata 

```bash
https://10.104.1.22:19999
https://seafile.linux.b2:19999
```

# Discord Notifications

```bash 
$ sudo nano /etc/netdata/health_alarm_notify.conf

# sending discord notifications

# note: multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1083672966522478602/1yYfwc6ofMy8smtwXIgTTaJYv3tFJx_wCPaNeOtGkBnDnFywSfSjHoQqxDyM5RdOd_LS"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="général"
```

```bash
$ sudo nano /etc/netdata/health.d/cpu_usage.conf

alarm: cpu_usage
on: system.cpu
lookup: average -3s percentage foreach user, system
units: %
every: 10s
warn: $this > 50
crit: $this > 80
info: CPU utilization of users on the system itself.
```

# Restart 

```bash
$ sudo systemctl restart netdata
```

# Verification : Discord Notifications

```bash
$ stress-ng --vm 2 --vm-bytes 1G --timeout 60s
```