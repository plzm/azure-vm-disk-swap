#!/bin/bash

echo "Get source VM Resource IDs"
vmIdV2=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_SRC_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
vmIdV3=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_SRC_NAME_V3" -o tsv --query "id")" | sed "s/\r//")


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_deallocate
echo "Deallocate Source VMs"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V2" --verbose
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V3" --verbose


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_generalize
echo "Generalize Source VMs"
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V2" --verbose
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V3" --verbose


# https://docs.microsoft.com/cli/azure/image?view=azure-cli-latest#az_image_create
echo "Create Source VM V2 Image"
az image create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" --verbose \
	-n "$VM_IMG_NAME_V2" --source "$vmIdV2" --os-type "$VM_OS_TYPE" --storage-sku "$OS_DISK_STORAGE_TYPE"

echo "Create Source VM V3 Image"
az image create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" --verbose \
	-n "$VM_IMG_NAME_V3" --source "$vmIdV3" --os-type "$VM_OS_TYPE" --storage-sku "$OS_DISK_STORAGE_TYPE"


# Get VM Image IDs for Gallery Image Version Creation
imageIdV2=$(echo "$(az image show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -n "$VM_IMG_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
imageIdV3=$(echo "$(az image show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -n "$VM_IMG_NAME_V3" -o tsv --query "id")" | sed "s/\r//")


# https://docs.microsoft.com/cli/azure/sig/image-version?view=azure-cli-latest#az_sig_image_version_create
echo "Create Source VM V2 Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -l "$LOCATION" --verbose \
	-r "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_V2" --gallery-image-version "$VM_IMG_DEF_VERSION_V2" \
	--managed-image "$imageIdV2" --target-regions "$LOCATION"

echo "Create Source VM V3 Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -l "$LOCATION" --verbose \
	-r "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_V3" --gallery-image-version "$VM_IMG_DEF_VERSION_V3" \
	--managed-image "$imageIdV3" --target-regions "$LOCATION"
