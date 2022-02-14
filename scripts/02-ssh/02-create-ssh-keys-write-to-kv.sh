#!/bin/bash

# Set Key Vault Secret expiration date to 1 year from today - adjust as needed
expirationDate="$(date +%s -d "$(date) + 1 year")"

# VM Admin user SSH public key - we assume we are provided ONLY a public key, not the private key, and that it is generated and managed outside this context.
# We use this to enable a deployed VM to be logged into and used by the user account whose public SSH key this is.
# This SSH key is not used in this context to log into the VM. It's added to the VM for eventual use by this user account.
# It's hard-coded here but of course if this is stored in the Key Vault used elsewhere here, you can just retrieve it from there at this point.
vmAdminSshPublicKeyInfix="AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw=="
VM_ADMIN_SSH_PUBLIC_KEY="ssh-rsa ""$vmAdminSshPublicKeyInfix"" ""$VM_ADMIN_SSH_USER_NAME"
#echo $VM_ADMIN_SSH_PUBLIC_KEY

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
	secretValue="$VM_ADMIN_SSH_PUBLIC_KEY" \
	expirationDate="$expirationDate"


# Deploy user SSH public and private keys
# In this context, we'll create a new key pair ONLY for deployment. This way, the source VMs, the OS disks, the deployed VM, etc. all only know
# about this SSH user (plus of course we configure the VM admin SSH public key below). This eliminates the risk of credential leak: the SSH user and keys
# are generated here - this could be your dev box, or a build server, or a CI/CD pipeline agent - and are as transient as you want.
# If this is a hosted build agent, this SSH public/private key pair's lifetime is only as long as the build agent's (plus a cleanup script is provided).
# Below we write the public AND private keys to Key Vault. The private key is only needed if it will be used again in a later deployment or other context.
# If the deployment SSH key will ONLY be used in a single context - e.g. a single pipeline execution - and will not be needed again later, the private key does not
# need to be written to Key Vault. Determine whether the private key should be persisted to Key Vault based on your circumstances and constraints.

# Clean up existing key files here, if any
delCmd="rm ./""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

# Generate new public and private key pair and write the files here
ssh-keygen -q -m "PEM" -f "./""$DEPLOYMENT_SSH_USER_KEY_NAME" -t "$DEPLOYMENT_SSH_KEY_TYPE" -b $DEPLOYMENT_SSH_KEY_BITS -N "$DEPLOYMENT_SSH_KEY_PASSPHRASE" -C "$DEPLOYMENT_SSH_USER_NAME"

# Read keys from file into variables
DEPLOYMENT_SSH_PRIVATE_KEY=$(<$DEPLOYMENT_SSH_USER_KEY_NAME)
#echo $DEPLOYMENT_SSH_PRIVATE_KEY # Obviously be very careful uncommenting this one... here for debug.
DEPLOYMENT_SSH_PUBLIC_KEY=$(<"$DEPLOYMENT_SSH_USER_KEY_NAME"".pub")
#echo $DEPLOYMENT_SSH_PUBLIC_KEY

# Move new SSH pub/priv key files to ~/.ssh
mkdir ~/.ssh
mv "./""$DEPLOYMENT_SSH_USER_KEY_NAME" ~/.ssh
mv "./""$DEPLOYMENT_SSH_USER_KEY_NAME"".pub" ~/.ssh

# Set SSH key file permissions
privCmd="chmod 600 ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
#echo $privCmd
eval $privCmd
pubCmd="chmod 644 ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"".pub"
#echo $pubCmd
eval $pubCmd

# Add SSH key to SSH agent
#eval $(ssh-agent)
ssh-add "~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"

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
