#!/bin/bash

. ./step00.variables.sh

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

vm1Id="$(az vm show --subscription "$subscriptionId" -g "$rgNameSource" -n "$vm1Name" -o tsv --query "id")"
vm2Id="$(az vm show --subscription "$subscriptionId" -g "$rgNameSource" -n "$vm2Name" -o tsv --query "id")"

# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_deallocate
echo "Deallocate Source VM1"
az vm deallocate --subscription "$subscriptionId" -g "$rgNameSource" --name "$vm1Name" --verbose

echo "Deallocate Source VM2"
az vm deallocate --subscription "$subscriptionId" -g "$rgNameSource" --name "$vm2Name" --verbose


# https://docs.microsoft.com/cli/azure/vm?view=azure-cli-latest#az_vm_generalize
echo "Generalize Source VM1"
az vm generalize --subscription "$subscriptionId" -g "$rgNameSource" --name "$vm1Name" --verbose

echo "Generalize Source VM2"
az vm generalize --subscription "$subscriptionId" -g "$rgNameSource" --name "$vm2Name" --verbose


# https://docs.microsoft.com/cli/azure/image?view=azure-cli-latest#az_image_create
echo "Create Source VM1 Image"
az image create --subscription "$subscriptionId" -g "$rgNameSig" --verbose \
	-n "$vm1ImageName" --source "$vm1Id" --os-type "$osType" --storage-sku "$osDiskStorageType"

echo "Create Source VM2 Image"
az image create --subscription "$subscriptionId" -g "$rgNameSig" --verbose \
	-n "$vm2ImageName" --source "$vm2Id" --os-type "$osType" --storage-sku "$osDiskStorageType"


# Get VM Image IDs for SIG Image Version Creation
image1Id="$(az image show --subscription "$subscriptionId" -g "$rgNameSig" -n "$vm1ImageName" -o tsv --query "id")"
image2Id="$(az image show --subscription "$subscriptionId" -g "$rgNameSig" -n "$vm2ImageName" -o tsv --query "id")"


# https://docs.microsoft.com/cli/azure/sig/image-version?view=azure-cli-latest#az_sig_image_version_create
echo "Create Source VM1 Shared Image Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$subscriptionId" -g "$rgNameSig" -l "$location" --verbose \
	-r "$sigName" --gallery-image-definition "$imageDefinition1" --gallery-image-version "$imageVersion1" \
	--managed-image "$image1Id" --target-regions "$location"

echo "Create Source VM2 Shared Image Gallery Image Version from generalized VM custom image"
az sig image-version create --subscription "$subscriptionId" -g "$rgNameSig" -l "$location" --verbose \
	-r "$sigName" --gallery-image-definition "$imageDefinition2" --gallery-image-version "$imageVersion2" \
	--managed-image "$image2Id" --target-regions "$location"
