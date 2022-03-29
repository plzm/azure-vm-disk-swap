#!/bin/bash
set -eu

# Get Azure Compute Gallery Version References
galleryImageRefVNext=$(echo "$(az sig image-version show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" --gallery-name "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_VNEXT" --gallery-image-version "$VM_IMG_DEF_VERSION_VNEXT" -o tsv --query "id")" | sed "s/\r//")

# Create managed OS disks from gallery image versions
# https://docs.microsoft.com/cli/azure/disk?view=azure-cli-latest#az_disk_create

echo "List VMs with tag AutoRefresh=true. We will create an OS disk for each of these."
tagKey="AutoRefresh"
tagValue="true"
vms="$(az vm list --subscription ""$SUBSCRIPTION_ID"" --query "[?tags.""$tagKey""=='""$tagValue""'].{vmName:name, vmRg:resourceGroup, vmLocation:location}")"

while read -r vmName vmRg vmLocation; do
	vmDiskName="$vmName""-""$VM_SUFFIX_VNEXT"
	echo "Create vNext OS disk ""$vmDiskName"" for VM ""$vmLocation""\\""$vmRg""\\""$vmName"

	az disk create --subscription "$SUBSCRIPTION_ID" -g "$vmRg" -l "$vmLocation" --verbose \
		-n "$vmDiskName" --gallery-image-reference "$galleryImageRefVNext" \
		--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"

done< <(echo "${vms}" | jq -r '.[] | "\(.vmName) \(.vmRg) \(.vmLocation)"')
