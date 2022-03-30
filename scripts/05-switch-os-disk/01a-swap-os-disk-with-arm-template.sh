#!/bin/bash
set -eu

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')" | sed "s/\r//")
fi

# Select all VMs with OSDiskName tag
# Compare tag value to current OS disk name
# If they differ, swap to the OS disk name in the OSDiskName tag value
# The tag value reflects what the OS disk SHOULD be - so modify the tag, then the script/pipeline will adjust the VM's state to what the tag says

# Get all VMs that have an OSDiskName tag (feel free to substitute your own logic for which VMs should be evaluated for OS disk swap)
tagKey="OSDiskName"

vms=$(echo "$(az vm list --subscription $SUBSCRIPTION_ID --query "[?tags.""$tagKey""]")" | sed "s/\r//")

while read -r vmId vmName vmRg vmLocation currentOsDiskName
do
	newOsDiskName=$(echo "$(az tag list --resource-id $vmId -o tsv --query "[properties.tags.""$tagKey""]")" | sed "s/\r//")
	#echo $vmId
	#echo $vmName
	#echo $vmRg
	#echo $vmLocation
	#echo "New OS Disk Name=""$newOsDiskName"
	#echo "Current OS Disk Name=""$currentOsDiskName"

	if [[ "$newOsDiskName" == "$currentOsDiskName" ]]
	then
		echo "$vmLocation""/""$vmRg""/""$vmName"": no OS disk change needed"
	else
		echo "$vmLocation""/""$vmRg""/""$vmName"": OS disk needs to be changed"

		newOsDiskId=$(echo "$(az disk show --subscription $SUBSCRIPTION_ID -g ""$vmRg"" -n ""$newOsDiskName"" -o tsv --query "id")" | sed "s/\r//")
		#echo $newOsDiskId

		if [[ ! -z $newOsDiskId ]]
		then
			echo "Disk referenced by tag value exists. Starting swap onto VM."

			echo "Deallocate VM"
			az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$vmRg" --name "$vmName" --verbose

			echo "Update the VM with new OS disk ID"
			# SPECIFY THE CORRECT OS DISK ID TO SWAP -->TO<-- WITH THE osDiskId PARAMETER
			az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$vmName""-OS-DISK" --verbose \
				-g "$vmRg" --template-uri "$TEMPLATE_VM" \
				--parameters \
				location="$vmLocation" \
				userAssignedManagedIdentityResourceId="$uamiResourceId" \
				virtualMachineName="$vmName" \
				virtualMachineSize="$VM_SIZE" \
				version="$VM_VERSION" \
				provisionVmAgent="$PROVISION_VM_AGENT" \
				adminUsername="$VM_ADMIN_SSH_USER_NAME" \
				adminSshPublicKey="$VM_ADMIN_SSH_PUBLIC_KEY" \
				virtualMachineTimeZone="$VM_TIME_ZONE" \
				osDiskId="$newOsDiskId" \
				dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
				dataDiskCount="$DATA_DISK_COUNT" \
				dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
				vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
				enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
				autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
				autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
				resourceGroupNameNetworkInterface="$RG_NAME_VM_PROD" \
				networkInterfaceName="$vmName"

			echo "Start VM"
			az vm start --subscription "$SUBSCRIPTION_ID" -g "$vmRg" -n "$vmName" --verbose

			echo "Get VM FQDN and public IP address"
			vmFqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$vmRg"" -n ""$vmName"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
			vmIp=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$vmRg"" -n ""$vmName"" -o tsv --query 'ipAddress')" | sed "s/\r//")

			echo "Clean VM out of SSH known hosts"
			ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdn"
			ssh-keygen -f ~/.ssh/known_hosts -R "$vmIp"
		fi
	fi
done< <(echo "${vms}" | jq -r '.[] | "\(.id) \(.name) \(.resourceGroup) \(.location) \(.storageProfile.osDisk.name)"')
