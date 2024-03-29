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

The Second NIC will will need the IP Address of 192.168.1.20/24 (use NetworkManager)

After you set the static IP to the aforementioned address, change the method in NetworkManager to "Shared with other computers" this should be under "Method" in NetworkManager, but remember it must be set to static first to set the IP

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
iptables -F
systemctl stop firewalld
```

Create the files
```bash
cp -r /usr/share/syslinux/* /var/lib/tftpboot
ln -s  /var/lib/tftpboot/ /tftpboot
mkdir /var/lib/tftpboot/pxelinux.cfg
```
Paste the following into ```/etc/dnsmasq.conf``` (Overwrite the existing config)
```bash
# DHCP range-leases [USE SECOND NIC INTERFACE]
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
Enter command: ```service dnsmasq restart```
## Prepare the OS

Copy repo for Fedora (30 in this example) if RHEL do the next part instead
```bash
cd /var/www/html
mkdir 30
cd 30
wget --mirror --cut-dirs 4 -nH ftp://mirror.csclub.uwaterloo.ca/fedora/linux/releases/30/Workstation/x86_64/os/
wget http://mirror.csclub.uwaterloo.ca/fedora/linux/releases/30/COMPOSE_ID
```
============[[[ FOR RHEL/CentOS ONLY ]]]============

Mount the ISO and copy the files to use as a repo
```bash
mount -o loop $NAME_OF_CENTOS.iso  /mnt
cp -r /mnt/*  /var/www/html/$NAME
```
===============================================

Copy initrd and kernel (vmlinuz) to /tftpboot/[name of os]

For [Fedora] net-install I download the iso then mount it and copy the files
(NOTE: The initrd and kernel might be in the repo that is mirrored, but these are untested)

For [RHEL/CentOS] the image should already be mounted from the pervious step so start at the "RHEL START" comment

```bash
cd ~/Downloads
wget https://dl.fedoraproject.org/pub/fedora/linux/releases/30/Workstation/x86_64/iso/Fedora-Workstation-netinst-x86_64-30-1.2.iso
mount -o loop Fedora-Workstation-netinst-x86_64-30-1.2.iso  /mnt

#RHEL START HERE
mkdir /var/lib/tftpboot/f30n #note folder name in this case for "Fedora 30 Netinst"

cp /mnt/images/pxeboot/vmlinuz  /var/lib/tftpboot/f30n
cp /mnt/images/pxeboot/initrd.img  /var/lib/tftpboot/f30n
```
## Configure the boot menu

Create file /tftpboot/pxelinux.cfg/default

Paste in the below text, the 2nd commented out entry can be used as a template for another OS entry

```bash
default menu.c32
prompt 0
timeout 3 #Timeout 10 is 1 second (Set to 3 here so it will autoboot)
ONTIMEOUT Fedora30 #When time out is done it will boot Fedora 30

MENU TITLE PXE Menu

LABEL Fedora30
kernel f30n/vmlinuz #kernel copied from earlier
#initrd copied from earlier                       #Kickstart file location                 #Local repo location
append initrd=f30n/initrd.img ramdisk_size=100000 ks=http://192.168.1.20/ks/ks.cfg ip=dhcp inst.repo=http://192.168.1.20/30/Workstation/x86_64/os/ devfs=nomount

#LABEL $OS_NAME
#kernel $foldername/vmlinuz
#append initrd=$foldername/initrd.img ramdisk_size=100000 ip=dhcp inst.repo=http://192.168.1.20/$repo devfs=nomount ks=http://192.168.1.20/ks/$ks
```
For RHEL/CentOS change ```inst.repo=``` to ```method=``` this is because it is not a netinstall but a clone of a disk

## Copy the Kickstart file 

Copy the Kickstart file (In this case from my github)

Note that in the pxelinux.cfg/defualt the ks= is set to /ks/ks.cfg

```bash
mkdir /var/www/html/ks
cd /var/www/html/ks
wget https://raw.githubusercontent.com/benderCRC/laptopKS/master/ks.cfg
```
## Copy the ChangePassword.sh script
I created a script that uses Expect and TCL to make it simple for the user to change the user and root password
It needs to be copied from my github to the /var/www/html/sh/ folder
```bash
cd /var/www/html
mkdir sh
cd sh
wget https://raw.githubusercontent.com/benderCRC/laptopKS/master/CHANGE_PASSWORD.sh
```
A readme for this script is automatically created on the users desktop by the postinstall in the ks.cfg

## Copy my KDE folder
This folder holds all the custom kde settings for the user
```bash
mkdir /var/www/html/kde
cd /var/www/html/kde

#From my github in this example
wget https://github.com/benderCRC/laptopKS/blob/master/kde/kde.zip?raw=true
unzip *
```

# Info on the KDE settings folder (ONLY FOR REDO)

## KDE Settings (OPTIONAL)

In my post install I use wget to copy KDE settings to the new install

I make a folder "/var/www/html/kde" which will hold these config files

Manually configure KDE on a box and copy the settings to this folder

```bash
cp ~/.config/plasma-org.kde.plasma.desktop-appletsrc /var/www/html/kde

cp ~/.kde/share/config/kdeglobals /var/www/html/kde
```

## Set autologon for KDE (OPTIONAL)

Since these are for new users I set there to be an autologon until they run the change password script.
I do this setting autologin in /etc/sddm.conf, then the conf file is deleted in my script to remove this
