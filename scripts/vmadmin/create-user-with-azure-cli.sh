#!/bin/bash
set -eux

# This uses VMAccessForLinux extension. Ensure this extension is not disallowed in your environment.
# If it is, you will need to use the custom script extension and an explicit script instead; see adjacent file.

echo "Add user and public SSH key to VM"
echo "Usage: ./create-user-with-azure-cli.sh \$vmResourceGroupName \$vmName \$vmUserName \$vmUserSshPublicKey"

vmResourceGroupName=$1
vmName=$2
vmUserName=$3
vmUserSshPublicKey=$4

az vm user update --subscription "$SUBSCRIPTION_ID" -g "$vmResourceGroupName" --verbose \
	-n "$vmName" --username "$vmUserName" --ssh-key-value "$vmUserSshPublicKey"
