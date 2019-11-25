# laptopKS

An Anaconda KS to securely wipe a laptop and install Fedora with specific extra packages

## NOTES

This only works for Redhat based Linux distros that use Anaconda. RHEL/CentOS/Scientific Linux will all work. 

Fedora will work, but it only supports loading Kickstart files when using the Netinstall. 
For Fedora it is best to feed it the netinstall and clone an install repo locally.

If you are doing diffrent systems it is important to see if the drivers are loaded automatically. If not figure out how to install them and use DMIDECODE on the post install to check for the system and install the drivers.

Example (Checks if laptop is ProBook 645 and if true installs the packages for the wifi driver)
```bash
prod=$(echo $(dmidecode |grep Prod | head -1))

hp645="Product Name: HP ProBook 645 G1"

if [ "$prod" ==  "$hp645" ];
then
  yum -y install kernel-devel-$(uname -r)
  yum -y install kmod-wl
fi
```
## Prerequisites

Install RHEL/CentOS/Fedora on a box with 2 NICs.

The first NIC will connect to the internet, and the second NIC will connect to a switch for the laptops to also connect to.

[A simple way to do this is use a laptop connected to the Nokia-BYOD Wifi and use the eth0 as the 2nd NIC]

The Second NIC will will need the IP Address of 192.168.1.20/24 (user NetworkManager)

After you set the static IP to the aforementioned address, change the methond in NetworkManager to "Shared with other computers" this should be under "Method" in NetworkManager, but remember it must be set to static first to set the IP

## Software Installation

Install the following software

```bash
yum install dnsmasq
yum install syslinux
yum install tftp-server
yum install httpd
```

Enable the Services
```bash
systemctl enable dnsmasq
systemctl enable httpd
```

Edit the Firewall
```bash
firewall-cmd --add-service=ftp --permanent  	## Port 21
firewall-cmd --add-service=http --permanent  	## Port 80
firewall-cmd --add-service=dns --permanent  	## Port 53
firewall-cmd --add-service=dhcp --permanent  	## Port 67
firewall-cmd --add-port=69/udp --permanent  	## Port for TFTP
firewall-cmd --add-port=4011/udp --permanent  ## Port for ProxyDHCP
firewall-cmd --reload  ## Apply rules
chkconfig iptables off #Turn off iptables
```

Create the files
```bash
cp -r /usr/share/syslinux/* /var/lib/tftpboot
ln -s  /var/lib/tftpboot/ /tftpboot
mkdir /var/lib/tftpboot/pxelinux.cfg
```

Copy repo for Fedora (30 in this example)
```bash
cd /var/www/html
mkdir 30
cd 30
wget -r ftp://mirror.csclub.uwaterloo.ca/fedora/linux/releases/30/Workstation/
```
Paste the following into /etc/dnsmasq.conf (Overwrite the existing config)
```bash
# DHCP range-leases
dhcp-range=enp1s0,192.168.1.3,192.168.1.253,255.255.255.0,1h
# PXE
dhcp-boot=pxelinux.0,pxeserver,192.168.1.20
# Gateway
dhcp-option=3,192.168.1.20
# DNS
dhcp-option=6,192.168.1.20, 8.8.8.8
server=8.8.4.4
# Broadcast Address
dhcp-option=28,10.0.0.255
# NTP Server
dhcp-option=42,0.0.0.0
enable-tftp
tftp-root=/var/lib/tftpboot
```

