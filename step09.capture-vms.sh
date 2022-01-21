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

vm1Id="$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM1_NAME" -o tsv --query "id")"
vm2Id="$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM2_NAME" -o tsv --query "id")"

# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_deallocate
echo "Deallocate Source VM1"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM1_NAME" --verbose

echo "Deallocate Source VM2"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM2_NAME" --verbose


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_generalize
echo "Generalize Source VM1"
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM1_NAME" --verbose

echo "Generalize Source VM2"
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM2_NAME" --verbose


# https://docs.microsoft.com/cli/azure/image?view=azure-cli-latest#az_image_create
echo "Create Source VM1 Image"
az image create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --verbose \
	-n "$VM1_IMAGE_NAME" --source "$vm1Id" --os-type "$VM_OS_TYPE" --storage-sku "$OS_DISK_STORAGE_TYPE"

echo "Create Source VM2 Image"
az image create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --verbose \
	-n "$VM2_IMAGE_NAME" --source "$vm2Id" --os-type "$VM_OS_TYPE" --storage-sku "$OS_DISK_STORAGE_TYPE"


# Get VM Image IDs for SIG Image Version Creation
image1Id="$(az image show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -n "$VM1_IMAGE_NAME" -o tsv --query "id")"
image2Id="$(az image show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -n "$VM2_IMAGE_NAME" -o tsv --query "id")"


# https://docs.microsoft.com/cli/azure/sig/image-version?view=azure-cli-latest#az_sig_image_version_create
echo "Create Source VM1 Shared Image Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMAGE_DEFINITION_1" --gallery-image-version "$VM_IMAGE_VERSION_1" \
	--managed-image "$image1Id" --target-regions "$LOCATION"

echo "Create Source VM2 Shared Image Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMAGE_DEFINITION_2" --gallery-image-version "$VM_IMAGE_VERSION_2" \
	--managed-image "$image2Id" --target-regions "$LOCATION"
