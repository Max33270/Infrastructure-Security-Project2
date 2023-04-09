# Automation Projet Infra/SI 

## Installations

```bash
sudo dnf install git -y 
git clone https://github.com/Max33270/Projet-Infra-SI
cd Projet-Infra-SI/Automation 
```

### 1. Serveur 
<br>
- Change the IP address to 10.104.1.20 <br> <br>

```bash
$ systemctl restart network
$ chmod +x serveur.sh
$ sudo ./serveur.sh
```

### 2. Database
<br>
- Change the IP address to 10.104.1.21 <br> <br>

```bash
chmod +x database.sh
sudo ./database.sh
```

### 3. Proxy
<br>
- Change the IP address to 10.104.1.22 <br> <br>

```bash
chmod +x proxy.sh
sudo ./proxy.sh
```

