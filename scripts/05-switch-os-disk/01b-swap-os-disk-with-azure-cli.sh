#!/bin/bash
set -eux

echo "Get the resource IDs of vNow and vNext OS disks"
vm1OsDiskIdVNow=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" -n "$VM_1_OS_DISK_NAME_VNOW" -o tsv --query "id")" | sed "s/\r//")
vm1OsDiskIdVNext=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" -n "$VM_1_OS_DISK_NAME_VNEXT" -o tsv --query "id")" | sed "s/\r//")

echo "TODO TODO TODO how to set this in a pipeline"
echo "Set the resource IDs of the OS disks to swap TO"
newVmOsDiskIdVm1=$vm1OsDiskIdVNow

echo "Deallocate VM so we can swap OS disk"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" --name "$VM_PROD_NAME_1" --verbose

# OPTIONAL in case you need to detach/re-attach data disk
#echo "Detach data disk"
#az vm disk detach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" --verbose \
#	--vm-name "$VM_PROD_NAME_1" -n "PROVIDE_DATA_DISK_NAME_HERE"

echo "Update the VM with new OS disk ID"
# SPECIFY THE CORRECT OS DISK ID TO SWAP -->TO<-- WITH THE --os-disk PARAMETER
az vm update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" --verbose \
	-n "$VM_PROD_NAME_1" --os-disk "$newVmOsDiskIdVm1"

echo "Start the VMs"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" -n "$VM_PROD_NAME_1" --verbose

# OPTIONAL in case you need to detach/re-attach data disks
#az vm disk attach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" --verbose \
#	--vm-name "$VM_PROD_NAME_1" -n "PROVIDE_DATA_DISK_NAME_HERE"
