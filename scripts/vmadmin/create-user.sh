#!/bin/bash
set -eux

vmUserName=$1
publicKeyInfix=$2
vmUserSshPublicKey="ssh-rsa ""$publicKeyInfix"" ""$vmUserName"

#echo $vmUserSshPublicKey

# Add user with sudo
sudo useradd -s /bin/bash -d "/home/""$vmUserName" -m -G sudo "$vmUserName"

# Create "/home/""$vmUserName"/.ssh directory
sudo mkdir -p "/home/""$vmUserName"/.ssh

# Write the public key to file, then move it to new user's home/user/.ssh
echo "$vmUserSshPublicKey" > id_"$vmUserName".pub
sudo mv id_"$vmUserName".pub /home/"$vmUserName"/.ssh/

# Add new user's public SSH key to their authorized_keys so they can SSH to the VM with their corresponding private key
sudo touch "/home/""$vmUserName"/.ssh/authorized_keys
sudo chmod 666 "/home/""$vmUserName"/.ssh/authorized_keys
sudo cat "/home/""$vmUserName"/.ssh/id_"$vmUserName".pub >> "/home/""$vmUserName"/.ssh/authorized_keys

# Secure the new user's SSH files nd folder
sudo chmod 600 "/home/""$vmUserName"/.ssh/authorized_keys
sudo chmod 644 "/home/""$vmUserName"/.ssh/id_"$vmUserName".pub
sudo chmod 700 "/home/""$vmUserName"/.ssh
sudo chown -R "$vmUserName":"$vmUserName" "/home/""$vmUserName"/.ssh
