#!/bin/bash

# Get Shared Image Gallery (SIG) Version References
sigImageReference1=$(echo "$(az sig image-version show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --gallery-name "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_V2" --gallery-image-version "$VM_IMG_DEF_VERSION_V2" -o tsv --query "id")" | sed "s/\r//")
sigImageReference2=$(echo "$(az sig image-version show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --gallery-name "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_V3" --gallery-image-version "$VM_IMG_DEF_VERSION_V3" -o tsv --query "id")" | sed "s/\r//")

# Create managed OS disks from SIG image versions
# https://docs.microsoft.com/cli/azure/disk?view=azure-cli-latest#az_disk_create

echo "Create Managed OS Disk 1"
az disk create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -l "$LOCATION" --verbose \
	-n "$VM_1_OS_DISK_NAME_V2" --gallery-image-reference "$sigImageReference1" \
	--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"

echo "Create Managed OS Disk 2"
az disk create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -l "$LOCATION" --verbose \
	-n "$VM_1_OS_DISK_NAME_V3" --gallery-image-reference "$sigImageReference2" \
	--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"
