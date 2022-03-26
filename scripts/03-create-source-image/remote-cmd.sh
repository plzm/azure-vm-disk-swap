#!/bin/bash
# This is the script to run remotely on source VMs

sudo apt update -y
sudo apt upgrade -y
sudo apt install nginx -y

sudo mkdir /usr/patrick_was_here
sudo touch /usr/patrick_was_here/foo.txt

#sudo chown -v -R root /patrick_was_here/  # This is so it doesn't get deleted as part of user deprovisioning
#sudo chmod 744 /patrick_was_here/

# Other configuration etc. etc.

#sudo waagent -deprovision+user -force -verbose
sudo waagent -deprovision -force -verbose
