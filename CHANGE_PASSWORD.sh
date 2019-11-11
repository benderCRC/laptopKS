#!/bin/bash
figlet -f banner change password
echo -e "\e[31mOld Password is password\e[0m"
passwd user
passwd root
rm -f /etc/sddm.conf
#rm -f $0 &
exit 0


yum install expect




#! /usr/bin/expect

spawn jarsigner ... # actual command here
expect "Enter Passphrase for keystore: "
send "jar_password\r"



spawn su
expect "assword"
send "password\r"

expect "root@"
send "passwd user\r"

expect 'password for user'
send 'test\r'

expect 'password for user'
send 'test\r'

send 'passwd root\r'
expect 'password for user'
send 'test\r'
expect 'password for user'
send 'test\r'