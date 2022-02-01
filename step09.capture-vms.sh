#!/bin/bash

# ##################################################
# IMPORTANT DO NOT SKIP THIS - READ THIS!!!!
# MAKE SURE YOU GENERALIZE THE VMs FIRST!!!!!
# Step 1 at https://docs.microsoft.com/azure/virtual-machines/linux/capture-image
# TODO - could add ssh and sudo waagent -deprovision here, depends if execution context has SSH key needed for that
# OTHERWISE - just SSH into your VMs and do step 1 (doc link above) there before actually running this .sh
# ##################################################
# DID YOU READ THE ABOVE? YOU REALLY SHOULD.
# ##################################################
# NOTE The following will fail if you generalized a VM with data disks > 1023 GB. If you have data disks > 1023 GB,
# detach the data disks before generalizing and proceeding. You will need to modify later steps to detach data disks
# before OS disk swap, then swap OS disk, then re-attach large data disks.
# ##################################################

vm1Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_NAME_IMG_SRC_1" -o tsv --query "id")" | sed "s/\r//")
vm2Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_NAME_IMG_SRC_2" -o tsv --query "id")" | sed "s/\r//")

# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_deallocate
echo "Deallocate Source VM1"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_1" --verbose

echo "Deallocate Source VM2"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_2" --verbose


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_generalize
echo "Generalize Source VM1"
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_1" --verbose

echo "Generalize Source VM2"
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_2" --verbose


# https://docs.microsoft.com/cli/azure/image?view=azure-cli-latest#az_image_create
echo "Create Source VM1 Image"
az image create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --verbose \
	-n "$VM_IMG_NAME_IMG_SRC_1" --source "$vm1Id" --os-type "$VM_OS_TYPE" --storage-sku "$OS_DISK_STORAGE_TYPE"

echo "Create Source VM2 Image"
az image create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --verbose \
	-n "$VM_IMG_NAME_IMG_SRC_2" --source "$vm2Id" --os-type "$VM_OS_TYPE" --storage-sku "$OS_DISK_STORAGE_TYPE"


# Get VM Image IDs for SIG Image Version Creation
image1Id=$(echo "$(az image show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -n "$VM_IMG_NAME_IMG_SRC_1" -o tsv --query "id")" | sed "s/\r//")
image2Id=$(echo "$(az image show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -n "$VM_IMG_NAME_IMG_SRC_2" -o tsv --query "id")" | sed "s/\r//")


# https://docs.microsoft.com/cli/azure/sig/image-version?view=azure-cli-latest#az_sig_image_version_create
echo "Create Source VM1 Shared Image Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEFINITION_IMG_SRC_1" --gallery-image-version "$VM_IMG_VERSION_IMG_SRC_1" \
	--managed-image "$image1Id" --target-regions "$LOCATION"

echo "Create Source VM2 Shared Image Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEFINITION_IMG_SRC_2" --gallery-image-version "$VM_IMG_VERSION_IMG_SRC_2" \
	--managed-image "$image2Id" --target-regions "$LOCATION"
