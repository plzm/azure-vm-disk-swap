#!/bin/bash

echo "Set Key Vault Secret expiration date to 1 year from today - adjust as needed"
expirationDate="$(date +%s -d "$(date) + 1 year")"

# VM Admin user SSH public key - we assume we are provided ONLY a public key, not the private key, and that it is generated and managed outside this context.
# We use this to enable a deployed VM to be logged into and used by the user account whose public SSH key this is.
# This SSH key is not used in this context to log into the VM. It's added to the VM for eventual use by this user account.
# It's hard-coded here but of course if this is stored in the Key Vault used elsewhere here, you can just retrieve it from there at this point.
vmAdminSshPublicKeyInfix="AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw=="
vmAdminSshPublicKey="ssh-rsa ""$vmAdminSshPublicKeyInfix"" ""$VM_ADMIN_SSH_USER_NAME"

#echo "Write VM Admin Username to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-VM-Admin-Username" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" \
	secretValue="$VM_ADMIN_SSH_USER_NAME" \
	expirationDate="$expirationDate"

#echo "Write VM Admin User SSH Public Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-VM-Admin-PubKey" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" \
	secretValue="$vmAdminSshPublicKey" \
	expirationDate="$expirationDate"


# Deploy user SSH public and private keys
# In this context, we'll create a new key pair ONLY for deployment. This way, the source VMs, the OS disks, the deployed VM, etc. all only know
# about this SSH user (plus of course we configure the VM admin SSH public key below). This eliminates the risk of credential leak: the SSH user and keys
# are generated here - this could be your dev box, or a build server, or a CI/CD pipeline agent - and are as transient as you want.
# If this is a hosted build agent, this SSH public/private key pair's lifetime is only as long as the build agent's (plus a cleanup script is provided).

sshKeyName="ssh-vm-deploy"
sshKeyType="ecdsa"
sshKeyBits=521
sshKeyPassphrase="" # Use blank for convenience here as SSH key will be short-lived
sshPublicKeyUsername="$DEPLOYMENT_SSH_USER_NAME"

ssh-keygen -q -f "./""$sshKeyName" -t "$sshKeyType" -b $sshKeyBits -N "$sshKeyPassphrase" -C "$sshPublicKeyUsername"

echo "Copy new SSH pub/priv key files to ~/.ssh"
mkdir ~/.ssh
cp "./""$sshKeyName" ~/.ssh
cp "./""$sshKeyName"".pub" ~/.ssh

echo "Set SSH key file permissions"
privCmd="sudo chmod 600 ~/.ssh/""$sshKeyName"
eval $privCmd
pubCmd="sudo chmod 644 ~/.ssh/""$sshKeyName"".pub"
eval $pubCmd

echo "Add SSH key to SSH agent"
eval $(ssh-agent)
sudo ssh-add

# Cleanup
# sudo ssh-add -d "~/.ssh/""$sshKeyName"


#echo "Write Deployment Username to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-Deploy-Username" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME" \
	secretValue="$DEPLOYMENT_SSH_USER_NAME" \
	expirationDate="$expirationDate"

#echo "Write Deployment User SSH Public Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-Deploy-PubKey" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" \
	secretValue="$DEPLOYMENT_SSH_PUBLIC_KEY" \
	expirationDate="$expirationDate"

#echo "Write Deployment User SSH Private Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-Deploy-PrivKey" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PRIVATE_KEY" \
	secretValue="$DEPLOYMENT_SSH_PRIVATE_KEY" \
	expirationDate="$expirationDate"
