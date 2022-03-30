#!/bin/bash
set -u

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

			# OPTIONAL in case you need to detach/re-attach data disk
			#echo "Detach data disk"
			#az vm disk detach --subscription "$SUBSCRIPTION_ID" -g "$vmRg" --verbose \
			#	--vm-name "$vmName" -n "PROVIDE_DATA_DISK_NAME_HERE"

			echo "Update the VM with new OS disk ID"
			# SPECIFY THE CORRECT OS DISK ID TO SWAP -->TO<-- WITH THE --os-disk PARAMETER
			az vm update --subscription "$SUBSCRIPTION_ID" -g "$vmRg" --verbose \
				-n "$vmName" --os-disk "$newOsDiskId"

			echo "Start VM"
			az vm start --subscription "$SUBSCRIPTION_ID" -g "$vmRg" -n "$vmName" --verbose

			# OPTIONAL in case you need to detach/re-attach data disks
			#az vm disk attach --subscription "$SUBSCRIPTION_ID" -g "$vmRg" --verbose \
			#	--vm-name "$vmName" -n "PROVIDE_DATA_DISK_NAME_HERE"

			echo "Get VM FQDN and public IP address"
			vmFqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$vmRg"" -n ""$vmName"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
			vmIp=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$vmRg"" -n ""$vmName"" -o tsv --query 'ipAddress')" | sed "s/\r//")

			echo "Clean VM out of SSH known hosts"
			ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdn"
			ssh-keygen -f ~/.ssh/known_hosts -R "$vmIp"
		fi
	fi
done< <(echo "${vms}" | jq -r '.[] | "\(.id) \(.name) \(.resourceGroup) \(.location) \(.storageProfile.osDisk.name)"')
