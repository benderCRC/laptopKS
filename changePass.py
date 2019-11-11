#!/usr/bin/env python
import pexpect

sudo = pexpect.spawn('bash -c "su"')

sudo.expect('Password:')

sudo.sendline('password')

sudo.expect('#')

sudo.sendline('passwd user')
sudo.expect('password for user')

sudo.sendline('test')
sudo.expect('password for user')
sudo.sendline('test')

sudo.sendline('passwd root')
sudo.expect('password for user')
sudo.sendline('test')
sudo.expect('password for user')
sudo.sendline('test')