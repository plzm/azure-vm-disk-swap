#!/bin/bash

. ./step00.variables.sh

echo "Get the resource IDs of the OS disks"
vm3OsDiskIdVersion0="$(az disk show --subscription "$subscriptionId" -g "$rgNameDeploy" -n "$vm3OsDiskNameVersion0" -o tsv --query "id")"
vm3OsDiskIdVersion1="$(az disk show --subscription "$subscriptionId" -g "$rgNameDeploy" -n "$vm3OsDiskNameVersion1" -o tsv --query "id")"
vm3OsDiskIdVersion2="$(az disk show --subscription "$subscriptionId" -g "$rgNameDeploy" -n "$vm3OsDiskNameVersion2" -o tsv --query "id")"

echo "Deallocate the existing VM so we can swap in a different OS disk"
az vm deallocate --subscription "$subscriptionId" -g "$rgNameDeploy" --name "$vm3Name" --verbose

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Get data disk ID"
#vm3DataDiskId1="$(az disk show --subscription "$subscriptionId" -g "$rgNameDeploy" -n "PROVIDE" -o tsv --query "id")"

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Detach data disk"
#az vm disk detach --subscription "$subscriptionId" -g "$rgNameDeploy" --verbose \
#	--vm-name "$vm3Name" -n "data-1"

echo "Update the VM with one of the new OS disk IDs"
# SPECIFY THE CORRECT OS DISK ID TO SWAP -->TO<-- WITH THE --os-disk PARAMETER
az vm update --subscription "$subscriptionId" -g "$rgNameDeploy" --verbose \
	-n "$vm3Name" --os-disk "$vm3OsDiskIdVersion1"

echo "Start the VM"
az vm start --subscription "$subscriptionId" -g "$rgNameDeploy" --verbose \
	-n "$vm3Name"

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Attach the data disk"
#az vm disk attach --subscription "$subscriptionId" -g "$rgNameDeploy" --verbose \
#	--vm-name "$vm3Name" -n "data-1"
