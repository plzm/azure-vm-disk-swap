#!/bin/bash

echo "Get source VM Resource IDs"
vm1Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_NAME_IMG_SRC_1" -o tsv --query "id")" | sed "s/\r//")
vm2Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_NAME_IMG_SRC_2" -o tsv --query "id")" | sed "s/\r//")


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_deallocate
echo "Deallocate Source VMs"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_1" --verbose
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_2" --verbose


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_generalize
echo "Generalize Source VMs"
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_1" --verbose
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
