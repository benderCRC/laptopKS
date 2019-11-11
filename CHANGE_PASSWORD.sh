#! /usr/bin/expect

#echo -e "\e[31mOld Password is password\e[0m"

#Login as Root
spawn /bin/bash -c "su"
expect "assword"
send "password\r"


#Change password of user
expect "root@"
send "passwd user\r"

expect "password for user"
send "testtesttest\r"

expect "password for user"
send "testtesttest\r"

#Change password for Root
send "passwd root\r"
expect "password for user"
send "testtesttest\r"
expect "password for user"
send "testtesttest\r"

#rm -f /etc/sddm.conf
#rm -f $0 &
#exit 0
