#!/bin/bash
set -eux

vmUserName=$1
vmUserSshPublicKey=$2

# Add user with sudo
sudo useradd -s /bin/bash -d "/home/""$vmUserName" -m -G sudo "$vmUserName"

# Create "/home/""$vmUserName"/.ssh directory
mkdir -p "/home/""$vmUserName"/.ssh

# Write the public key to "/home/""$vmUserName"/.ssh directory in a public key file named for the user
echo "$vmUserSshPublicKey" > "/home/""$vmUserName"/.ssh/"$vmUserName".pub

# Secure the .ssh directory and the public key file
sudo chmod 700 "/home/""$vmUserName"/.ssh;
sudo chmod 644 "/home/""$vmUserName"/.ssh/"$vmUserName".pub
sudo chown -R "$vmUserName":"$vmUserName" "/home/""$vmUserName"/.ssh
