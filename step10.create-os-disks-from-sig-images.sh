#!/bin/bash

# Get Shared Image Gallery (SIG) Version References
sigImageReference1="$(az sig image-version show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --gallery-name "$SIG_NAME" --gallery-image-definition "$VM_IMAGE_DEFINITION_1" --gallery-image-version "$VM_IMAGE_VERSION_1" -o tsv --query "id")"
sigImageReference2="$(az sig image-version show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --gallery-name "$SIG_NAME" --gallery-image-definition "$VM_IMAGE_DEFINITION_2" --gallery-image-version "$VM_IMAGE_VERSION_2" -o tsv --query "id")"

# Create managed OS disks from SIG image versions
# https://docs.microsoft.com/cli/azure/disk?view=azure-cli-latest#az_disk_create

echo "Create Managed OS Disk 1"
az disk create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -l "$LOCATION" --verbose \
	-n "$VM3_OS_DISK_NAME_2" --gallery-image-reference "$sigImageReference1" \
	--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"

echo "Create Managed OS Disk 2"
az disk create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -l "$LOCATION" --verbose \
	-n "$VM3_OS_DISK_NAME_3" --gallery-image-reference "$sigImageReference2" \
	--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"
