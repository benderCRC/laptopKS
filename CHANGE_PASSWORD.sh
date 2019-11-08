#!/bin/bash
figlet -f banner change password
echo -e "\e[31mOld Password is password\e[0m"
passwd
rm -f /etc/sddm.conf
rm -f $0 &
exit 0
