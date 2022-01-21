#!/bin/bash

echo "Retrieve new Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT was only to put them INTO Key Vault in step04.
vmNewAdminUsername="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_NEW_ADMIN_USERNAME" -o tsv --query 'value')"
vmNewAdminUserSshPublicKey="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_NEW_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')"

# If a Managed Identity Name was provided, get its Principal ID for the custom script extension deploy below
# This is useful if the custom script task is modified to retrieve a file from an Azure Storage account where the managed identity has access permissions
if [ ! -z $USERNAME_UAMI ]
then
	uamiPrincipalId="$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'principalId')"
fi

# RHEL
script="
sudo useradd ""$vmNewAdminUsername"";
sudo usermod -aG wheel ""$vmNewAdminUsername"";
sudo mkdir -p /home/""$vmNewAdminUsername""/.ssh;
sudo echo \"""$vmNewAdminUserSshPublicKey""\"  > ""$vmNewAdminUsername"".txt;
sudo cp ./""$vmNewAdminUsername"".txt /home/""$vmNewAdminUsername""/.ssh/authorized_keys;
sudo rm ""$vmNewAdminUsername"".txt;
sudo chmod 700 /home/""$vmNewAdminUsername""/.ssh;
sudo chmod 600 /home/""$vmNewAdminUsername""/.ssh/authorized_keys;
sudo chown -R ""$vmNewAdminUsername"":""$vmNewAdminUsername"" /home/""$vmNewAdminUsername""/.ssh;
sudo echo \"""$vmNewAdminUsername""	ALL=(ALL)	NOPASSWD: ALL\" > /etc/sudoers.d/020_""$vmNewAdminUsername"";
"

# TODO - Ubuntu version of above script - will need to change the usermod line to make new user an admin

echo "Create a new admin user"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-Ext-CustomScript-""$LOCATION" --verbose \
	-g "$RG_NAME_DEPLOY" --template-file "$TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM3_NAME" \
	script="$script" \
	managedIdentity="$uamiPrincipalId"
