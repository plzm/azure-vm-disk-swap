#!/bin/bash

echo "Retrieve VM Admin Username and SSH Public Key from Key Vault"
vmAdminSshUserName=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

#echo $vmAdminSshUserName
#echo $vvmAdminSshPublicKey

# If a Managed Identity Name was provided, get its Principal ID for the custom script extension deploy below
# This is useful if the custom script task is modified to retrieve a file from an Azure Storage account where the managed identity has access permissions
if [ ! -z $USERNAME_UAMI ]
then
	uamiPrincipalId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'principalId')" | sed "s/\r//")
fi

# RHEL
script="
sudo useradd ""$vmAdminSshUserName"";
sudo usermod -aG wheel ""$vmAdminSshUserName"";
sudo mkdir -p /home/""$vmAdminSshUserName""/.ssh;
sudo echo \"""$vvmAdminSshPublicKey""\"  > ""$vmAdminSshUserName"".txt;
sudo cp ./""$vmAdminSshUserName"".txt /home/""$vmAdminSshUserName""/.ssh/authorized_keys;
sudo rm ""$vmAdminSshUserName"".txt;
sudo chmod 700 /home/""$vmAdminSshUserName""/.ssh;
sudo chmod 600 /home/""$vmAdminSshUserName""/.ssh/authorized_keys;
sudo chown -R ""$vmAdminSshUserName"":""$vmAdminSshUserName"" /home/""$vmAdminSshUserName""/.ssh;
sudo echo \"""$vmAdminSshUserName""	ALL=(ALL)	NOPASSWD: ALL\" > /etc/sudoers.d/020_""$vmAdminSshUserName"";
"

# TODO - Ubuntu version of above script - will need to change the usermod line to make new user an admin

echo "Add admin user and public SSH key to VM1"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-Ext-CustomScript-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_SRC_NAME_V2" \
	script="$script" \
	managedIdentity="$uamiPrincipalId"

echo "Add admin user and public SSH key to VM2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-Ext-CustomScript-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_SRC_NAME_V2" \
	script="$script" \
	managedIdentity="$uamiPrincipalId"
