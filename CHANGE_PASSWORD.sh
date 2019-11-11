#! /usr/bin/expect

proc getPass {prompt} {
  package require Expect
  set oldmode [stty -echo -raw]
  send_user "$prompt"
  set timeout -1
  expect_user -re "(.*)\n"
  send_user "\n"
  eval stty $oldmode
  return $expect_out(1,string)
}

#echo -e "\e[31mOld Password is password\e[0m"

#end_user "Enter New Password"
set pass  [getPass "Password    : "]
#puts {}
#puts "You entered password : \"$pass\""

#Login as Root
spawn /bin/bash -c "su"
expect "assword"
send "password\r"


#Change password of user
expect "root@"
send "passwd user\r"

expect "password for user"
sleep 2
send "$pass\r"

expect "password"
sleep 2
send "$pass\r"

#Change password for Root
expect "root@"
send "passwd root\r"
expect "password for user"
sleep2
send "$pass\r"
expect "password"
sleep 2
send "$pass\r"

#rm -f /etc/sddm.conf
#rm -f $0 &
#exit 0
