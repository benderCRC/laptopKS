# laptopKS

An Anaconda KS to securely wipe a laptop and install Fedora with specific extra packages

## Prerequisites

Install RHEL/CentOS/Fedora on a box with 2 NICs.

The first NIC will connect to the internet, and the second NIC will connect to a switch for the laptops to also connect to.

The Second NIC will will need the IP Address of 192.168.1.20/24

## Software Installation

Install the following software

```bash
yum install dnsmasq
yum install syslinux
yum install tftp-server
yum install tftp-server
yum install vsftpd
yum install httpd
```

Enable the Services
```bash
systemctl enable dnsmasq
systemctl enable vsftpd
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
```

Create the files
```bash
ln -s  /var/lib/tftpboot/ /tftpboot
mkdir /var/lib/tftpboot/pxelinux.cfg
```

```python
import foobar

foobar.pluralize('word') # returns 'words'
foobar.pluralize('goose') # returns 'geese'
foobar.singularize('phenomena') # returns 'phenomenon'
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)