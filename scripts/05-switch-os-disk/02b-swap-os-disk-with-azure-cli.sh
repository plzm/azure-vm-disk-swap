#!/bin/bash

echo "Get the resource IDs of the OS disks"
vmOsDiskId1=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V1" -o tsv --query "id")" | sed "s/\r//")
vmOsDiskId2=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
vmOsDiskId3=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V3" -o tsv --query "id")" | sed "s/\r//")

echo "Set the resource ID of the OS disk to swap TO"
vmOsDiskIdToSwapTo=$vmOsDiskId2

echo "Deallocate the existing VM so we can swap in a different OS disk"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_1" --verbose

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Get data disk ID"
#vm3DataDiskId1="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "PROVIDE" -o tsv --query "id")"

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Detach data disk"
#az vm disk detach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM_NAME_1" -n "data-1"

echo "Update the VM with one of the new OS disk IDs"
# SPECIFY THE CORRECT OS DISK ID TO SWAP -->TO<-- WITH THE --os-disk PARAMETER
az vm update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM_NAME_1" --os-disk "$vmOsDiskIdToSwapTo"

echo "Start the VM"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM_NAME_1"

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Attach the data disk"
#az vm disk attach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM_NAME_1" -n "data-1"
