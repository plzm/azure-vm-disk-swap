#!/bin/bash

# In this script, we retrieve SSH key info from Key Vault and set it locally to enable the current context to SSH to deployed image source VMs.
# This may seem redundant (why are we creating local SSH for deployment user, then writing to KV, then deleting local files in previous steps?) but...
# I am showing how to decouple all of this. You could run this step in a whole different context (or build agent, or pipeline) than the previous
# SSH key gen/write to KV/delete steps, showing how they can be separated. In effect, in this script/step we are starting clean and getting what we need from KV.

#vmDeploySshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")
#vmDeploySshPrivateKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PRIVATE_KEY" -o tsv --query 'value')" | sed "s/\r//")

#vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

vmDeploySshPublicKey="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" -o tsv --query 'value')"
vmDeploySshPrivateKey="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PRIVATE_KEY" -o tsv --query 'value')"

vmAdminSshPublicKey="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')"

#echo $vmAdminSshPublicKey
#echo $vmDeploySshPublicKey
#echo $vmDeploySshPrivateKey

# Write deployment user public and private keys to file
echo $vmDeploySshPrivateKey > "./""$DEPLOYMENT_SSH_USER_KEY_NAME"
echo $vmDeploySshPublicKey > "./""$DEPLOYMENT_SSH_USER_KEY_NAME"".pub"
# Write admin public key to file
echo $vmAdminSshPublicKey > "./""$VM_ADMIN_SSH_USER_KEY_NAME"".pub"

# Move SSH key files to ~/.ssh
mkdir ~/.ssh
mv "./""$DEPLOYMENT_SSH_USER_KEY_NAME" ~/.ssh
mv "./""$DEPLOYMENT_SSH_USER_KEY_NAME"".pub" ~/.ssh
mv "./""$VM_ADMIN_SSH_USER_KEY_NAME"".pub" ~/.ssh

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
#eval $(ssh-agent)
ssh-add "~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
