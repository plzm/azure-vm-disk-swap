#!/bin/bash
set -eux

vmUserName=$1
vmUserSshPublicKey=$2

# Add user with sudo
sudo useradd -s /bin/bash -d "/home/""$vmUserName" -m -G sudo "$vmUserName"

# Create ~/.ssh directory
mkdir -p ~/.ssh

# Write the public key to ~/.ssh directory in a public key file named for the user
echo $vmUserSshPublicKey > ~/.ssh/"$vmUserName".pub

# Secure the .ssh directory and the public key file
sudo chmod 700 ~/.ssh;
sudo chmod 644 ~/.ssh/"$vmUserName".pub
sudo chown -R "$vmUserName":"$vmUserName" ~/.ssh

