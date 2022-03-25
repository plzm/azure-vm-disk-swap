#!/bin/bash
set -eux

echo "Get source VM Resource IDs"
vmIdVNext=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_SOURCE" -n "$VM_SRC_NAME_VNEXT" -o tsv --query "id")" | sed "s/\r//")


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_deallocate
echo "Deallocate Source VM"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_SOURCE" --name "$VM_SRC_NAME_VNEXT" --verbose


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_generalize
echo "Generalize Source VM"
az vm generalize --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_SOURCE" --name "$VM_SRC_NAME_VNEXT" --verbose


# https://docs.microsoft.com/cli/azure/image?view=azure-cli-latest#az_image_create
echo "Create Source VM Image"
az image create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" --verbose \
	-n "$VM_IMG_NAME_VNEXT" --source "$vmIdVNext" --os-type "$VM_OS_TYPE" --storage-sku "$OS_DISK_STORAGE_TYPE"

# Get VM Image ID for Gallery Image Version Creation
imageIdVNext=$(echo "$(az image show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -n "$VM_IMG_NAME_VNEXT" -o tsv --query "id")" | sed "s/\r//")


# https://docs.microsoft.com/cli/azure/sig/image-version?view=azure-cli-latest#az_sig_image_version_create
echo "Create Source VM vNext Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -l "$LOCATION" --verbose \
	-r "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_VNEXT" --gallery-image-version "$VM_IMG_DEF_VERSION_VNEXT" \
	--managed-image "$imageIdVNext" --target-regions "$LOCATION"
