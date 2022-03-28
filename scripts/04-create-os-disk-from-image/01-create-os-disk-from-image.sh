#!/bin/bash
set -eu

# Get Shared Image Gallery (SIG) Version References
sigImageRefVNext=$(echo "$(az sig image-version show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" --gallery-name "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_VNEXT" --gallery-image-version "$VM_IMG_DEF_VERSION_VNEXT" -o tsv --query "id")" | sed "s/\r//")

# Create managed OS disks from SIG image versions
# https://docs.microsoft.com/cli/azure/disk?view=azure-cli-latest#az_disk_create

echo "Get list of VMs for which to create OS disk vNext; we'll get a list of all VMs in the subscription with a specific tag. Adjust to your criteria as needed."
myTag="Prod"
vms="$(az vm list --subscription ""$SUBSCRIPTION_ID"" --query "[?tags.Category=='""$myTag""'].{vmName:name, vmRg:resourceGroup}")"

echo "Iterate through each VM and create OS disk vNext for it"
while read -r vmName vmRg; do
	echo "Create vNext OS disk for VM ""$vmRg""\\""$vmName"
	
done< <(echo "${vms}" | jq -r '.[] | "\(.vmName) \(.vmRg)"')


#echo "Create VM1 OS Disk vNext"
#az disk create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" -l "$LOCATION" --verbose \
#	-n "$VM_1_OS_DISK_NAME_VNEXT" --gallery-image-reference "$sigImageRefVNext" \
#	--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"
