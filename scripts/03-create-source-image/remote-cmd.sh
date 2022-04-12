#!/bin/bash
# This is the script to run remotely on source VMs

# Normal update/upgrade
sudo apt update -y
sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Other installs etc. etc.

# Some file system stuff
sudo mkdir /usr/patrick_was_here
sudo touch /usr/patrick_was_here/foo.txt
sudo chown -v -R root /patrick_was_here/
sudo chmod 744 /patrick_was_here/

# Other configuration etc. etc.

# Deprovision the VM and delete the user
sudo waagent -deprovision+user -force -verbose
