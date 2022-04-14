#!/bin/bash
set -eu

# Create managed OS disks from gallery image versions
# https://docs.microsoft.com/cli/azure/disk?view=azure-cli-latest#az_disk_create

# Get Azure Compute Gallery Version References
galleryImageRefVNext=$(echo "$(az sig image-version show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" --gallery-name "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_VNEXT" --gallery-image-version "$VM_IMG_DEF_VERSION_VNEXT" -o tsv --query "id")" | sed "s/\r//")

echo "List VMs with tag AutoRefresh=true. We will create an OS disk for each of these."
vms="$(az graph query -q 'Resources | where type =~ "microsoft.compute/virtualmachines" and tags.AutoRefresh =~ "true" | project id, name, location, resourceGroup' --subscription ""$SUBSCRIPTION_ID"" --query 'data[].{id:id, name:name, location:location, resourceGroup:resourceGroup}')"

while read -r id name location resourceGroup; do
	#echo $id
	#echo $name
	#echo $location
	#echo $resourceGroup

	diskName="$name""-""$VM_SUFFIX_VNEXT"

	echo "Create vNext OS disk ""$diskName"" for VM ""$location""\\""$resourceGroup""\\""$name"
	az disk create --subscription "$SUBSCRIPTION_ID" -g "$resourceGroup" -l "$location" --verbose \
		-n "$diskName" --gallery-image-reference "$galleryImageRefVNext" \
		--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"

done< <(echo "${vms}" | jq -r '.[] | "\(.id) \(.name) \(.location) \(.resourceGroup)"')
