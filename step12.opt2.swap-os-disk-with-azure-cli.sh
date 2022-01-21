#!/bin/bash

echo "Get the resource IDs of the OS disks"
vm3OsDiskIdVersion0="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM3_OS_DISK_NAME_1" -o tsv --query "id")"
vm3OsDiskIdVersion1="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM3_OS_DISK_NAME_2" -o tsv --query "id")"
vm3OsDiskIdVersion2="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM3_OS_DISK_NAME_3" -o tsv --query "id")"

echo "Deallocate the existing VM so we can swap in a different OS disk"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM3_NAME" --verbose

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Get data disk ID"
#vm3DataDiskId1="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "PROVIDE" -o tsv --query "id")"

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Detach data disk"
#az vm disk detach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM3_NAME" -n "data-1"

echo "Update the VM with one of the new OS disk IDs"
# SPECIFY THE CORRECT OS DISK ID TO SWAP -->TO<-- WITH THE --os-disk PARAMETER
az vm update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM3_NAME" --os-disk "$vm3OsDiskIdVersion1"

echo "Start the VM"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM3_NAME"

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Attach the data disk"
#az vm disk attach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM3_NAME" -n "data-1"
