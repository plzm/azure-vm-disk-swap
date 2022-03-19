#!/bin/bash

# Deployment user SSH public and private keys
# In this context, we'll create a new key pair ONLY for deployment. This way, the source VMs, the OS disks, the deployed VM, etc. all only know
# about this SSH user (plus of course we configure the VM admin SSH public key below). This eliminates the risk of credential leak: the SSH user and keys
# are generated here - this could be your dev box, or a build server, or a CI/CD pipeline agent - and are as transient as you want.

# If this is a hosted build agent, this SSH public/private key pair's lifetime is only as long as the build agent's.

# Clean up existing key files, if any
delCmd="rm ./""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd
delCmd="rm ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

# Generate new deployment user public and private key pair and write the files here
ssh-keygen -q -m "PEM" -f "./""$DEPLOYMENT_SSH_USER_KEY_NAME" -t "$DEPLOYMENT_SSH_KEY_TYPE" -b $DEPLOYMENT_SSH_KEY_BITS -N "$DEPLOYMENT_SSH_KEY_PASSPHRASE" -C "$DEPLOYMENT_SSH_USER_NAME"

# Also write a file for the admin public key
echo $VM_ADMIN_SSH_PUBLIC_KEY > "./""$VM_ADMIN_SSH_USER_KEY_NAME"".pub"

# Move SSH key files to ~/.ssh
mkdir -p ~/.ssh
mv "./""$DEPLOYMENT_SSH_USER_KEY_NAME" ~/.ssh
cp "./""$DEPLOYMENT_SSH_USER_KEY_NAME"".pub" ~/.ssh
cp "./""$VM_ADMIN_SSH_USER_KEY_NAME"".pub" ~/.ssh

# Set SSH key file permissions
# Private key - restrictive
privCmd="chmod 600 ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
#echo $privCmd
eval $privCmd

# Public keys - less restrictive
pubCmd="chmod 644 ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"".pub"
#echo $pubCmd
eval $pubCmd

pubCmd="chmod 644 ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"".pub"
#echo $pubCmd
eval $pubCmd

# Add deployment private SSH key to SSH agent
eval $(ssh-agent)
sshAddCmd="ssh-add ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
eval $sshAddCmd