#!/bin/bash
set -eux

# This uses VMAccessForLinux extension. Ensure this extension is not disallowed in your environment.
# If it is, you will need to use the custom script extension and an explicit script instead; see adjacent file.

echo "Delete user and home folder from VM"
echo "Usage: ./delete-user-with-azure-cli.sh \$vmResourceGroupName \$vmName \$vmUserName"

vmResourceGroupName=$1
vmName=$2
vmUserName=$3

az vm user delete --subscription "$SUBSCRIPTION_ID" -g "$vmResourceGroupName" --verbose \
	-n "$vmName" --username "$vmUserName"
