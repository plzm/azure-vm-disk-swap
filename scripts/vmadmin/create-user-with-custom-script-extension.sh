#!/bin/bash
set -eux

echo "Add user and public SSH key to VM using Azure Custom Script Extension"
echo "Usage: ./create-user-with-custom-script-extension.sh \$vmResourceGroupName \$vmName \$vmUserName \$vmUserSshPublicKey"

vmResourceGroupName=$1
vmName=$2
vmUserName=$3
vmUserSshPublicKey=$4

# If a Managed Identity Name was provided, get its Principal ID for the custom script extension deploy below
# This is useful if the custom script task is modified to retrieve a file from an Azure Storage account where the managed identity has access permissions
if [ ! -z $USERNAME_UAMI ]
then
	uamiPrincipalId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'principalId')" | sed "s/\r//")
fi

# RHEL
script="
sudo useradd ""$vmUserName"";
sudo usermod -aG wheel ""$vmUserName"";
sudo mkdir -p /home/""$vmUserName""/.ssh;
sudo echo \"""$vmUserSshPublicKey""\"  > ""$vmUserName"".pub;
sudo cp ./""$vmUserName"".pub /home/""$vmUserName""/.ssh/authorized_keys;
sudo rm ""$vmUserName"".pub;
sudo chmod 700 /home/""$vmUserName""/.ssh;
sudo chmod 600 /home/""$vmUserName""/.ssh/authorized_keys;
sudo chown -R ""$vmUserName"":""$vmUserName"" /home/""$vmUserName""/.ssh;
sudo echo \"""$vmUserName""	ALL=(ALL)	NOPASSWD: ALL\" > /etc/sudoers.d/020_""$vmUserName"";
"

# TODO - Ubuntu version of above script - will need to change the usermod line to make new user an admin

az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-Ext-CustomScript" --verbose \
	-g "$vmResourceGroupName" --template-uri "$TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$vmName" \
	script="$script" \
	managedIdentity="$uamiPrincipalId"
