#!/bin/bash
set -eux

# If a Managed Identity Name was provided, get its Principal ID for the custom script extension deploy below
# This is useful if the custom script task is modified to retrieve a file from an Azure Storage account where the managed identity has access permissions
if [ ! -z $USERNAME_UAMI ]
then
	uamiPrincipalId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'principalId')" | sed "s/\r//")
fi

# RHEL
script="
sudo useradd ""$VM_ADMIN_SSH_USER_NAME"";
sudo usermod -aG wheel ""$VM_ADMIN_SSH_USER_NAME"";
sudo mkdir -p /home/""$VM_ADMIN_SSH_USER_NAME""/.ssh;
sudo echo \"""$vVM_ADMIN_SSH_PUBLIC_KEY""\"  > ""$VM_ADMIN_SSH_USER_NAME"".txt;
sudo cp ./""$VM_ADMIN_SSH_USER_NAME"".txt /home/""$VM_ADMIN_SSH_USER_NAME""/.ssh/authorized_keys;
sudo rm ""$VM_ADMIN_SSH_USER_NAME"".txt;
sudo chmod 700 /home/""$VM_ADMIN_SSH_USER_NAME""/.ssh;
sudo chmod 600 /home/""$VM_ADMIN_SSH_USER_NAME""/.ssh/authorized_keys;
sudo chown -R ""$VM_ADMIN_SSH_USER_NAME"":""$VM_ADMIN_SSH_USER_NAME"" /home/""$VM_ADMIN_SSH_USER_NAME""/.ssh;
sudo echo \"""$VM_ADMIN_SSH_USER_NAME""	ALL=(ALL)	NOPASSWD: ALL\" > /etc/sudoers.d/020_""$VM_ADMIN_SSH_USER_NAME"";
"

# TODO - Ubuntu version of above script - will need to change the usermod line to make new user an admin

echo "Add admin user and public SSH key to v2 VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-Ext-CustomScript" --verbose \
	-g "$RG_NAME_VM_SOURCE" --template-uri "$TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_SRC_NAME_V2" \
	script="$script" \
	managedIdentity="$uamiPrincipalId"

echo "Add admin user and public SSH key to v3 VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-Ext-CustomScript" --verbose \
	-g "$RG_NAME_VM_SOURCE" --template-uri "$TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_SRC_NAME_V3" \
	script="$script" \
	managedIdentity="$uamiPrincipalId"
