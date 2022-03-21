#!/bin/bash

echo "Get the resource IDs of the OS disks"
vm1OsDiskIdV1=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V1" -o tsv --query "id")" | sed "s/\r//")
vm1OsDiskIdV2=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
vm1OsDiskIdV3=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V3" -o tsv --query "id")" | sed "s/\r//")

vm2OsDiskIdV1=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_2_OS_DISK_NAME_V1" -o tsv --query "id")" | sed "s/\r//")
vm2OsDiskIdV2=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_2_OS_DISK_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
vm2OsDiskIdV3=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_2_OS_DISK_NAME_V3" -o tsv --query "id")" | sed "s/\r//")



echo "TODO TODO TODO how to set this in a pipeline"
echo "Set the resource IDs of the OS disks to swap TO"
newVmOsDiskIdVm1=$vm1OsDiskIdV2
newVmOsDiskIdVm2=$vm2OsDiskIdV2



echo "Deallocate the existing VMs so we can swap in different OS disks"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_1" --verbose
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_2" --verbose


# OPTIONAL in case you need to detach/re-attach data disk
#echo "Detach data disk"
#az vm disk detach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM_PROD_NAME_1" -n "PROVIDE_DATA_DISK_NAME_HERE"

#az vm disk detach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM_PROD_NAME_2" -n "PROVIDE_DATA_DISK_NAME_HERE"



echo "Update the VMs with one of the new OS disk IDs"
# SPECIFY THE CORRECT OS DISK ID TO SWAP -->TO<-- WITH THE --os-disk PARAMETER
az vm update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM_PROD_NAME_1" --os-disk "$newVmOsDiskIdVm1"

az vm update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM_PROD_NAME_2" --os-disk "$newVmOsDiskIdVm2"


echo "Start the VMs"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_PROD_NAME_1" --verbose
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_PROD_NAME_2" --verbose

s
# OPTIONAL in case you need to detach/re-attach data disks
#az vm disk attach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM_PROD_NAME_1" -n "PROVIDE_DATA_DISK_NAME_HERE"

#az vm disk attach --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
#	--vm-name "$VM_PROD_NAME_2" -n "PROVIDE_DATA_DISK_NAME_HERE"
