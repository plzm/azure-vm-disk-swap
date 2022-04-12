#!/bin/bash
set -eux

vmUserName=$1
publicKeyInfix=$2
vmUserSshPublicKey="ssh-rsa ""$publicKeyInfix"" ""$vmUserName"

# Add user
sudo useradd -s /bin/bash -d "/home/""$vmUserName" -m -G sudo "$vmUserName"

# Create "/home/""$vmUserName"/.ssh directory
sudo mkdir -p "/home/""$vmUserName"/.ssh

# Write public key file and add to authorized_keys for user
echo "$vmUserSshPublicKey" | sudo tee -a "/home/""$vmUserName""/.ssh/id_""$vmUserName"".pub"
echo "$vmUserSshPublicKey" | sudo tee -a "/home/""$vmUserName""/.ssh/authorized_keys"

# Secure the new user's SSH files and folder
sudo chmod 600 "/home/""$vmUserName"/.ssh/authorized_keys
sudo chmod 644 "/home/""$vmUserName"/.ssh/id_"$vmUserName".pub
sudo chmod 700 "/home/""$vmUserName"/.ssh
sudo chown -R "$vmUserName":"$vmUserName" "/home/""$vmUserName"/.ssh
