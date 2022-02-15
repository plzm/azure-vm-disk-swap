#!/bin/bash

# ##################################################
# IMPORTANT DO NOT SKIP THIS - READ THIS!!!!
# This script automatically generalizes the VMs. You do NOT need to do this manually. However! It is still a good idea for you to read step 1 here:
# https://docs.microsoft.com/azure/virtual-machines/linux/capture-image
# ##################################################
# NOTE The following will fail if you generalized a VM with data disks > 1023 GB. If you have data disks > 1023 GB,
# detach the data disks before generalizing and proceeding. You will need to modify later steps to detach data disks
# before OS disk swap, then swap OS disk, then re-attach large data disks.
# See ../05-switch-os-disks/05-prep-data-disks.sh for helper script.
# ##################################################

doTheSsh() {
  cmd=$1

  code=1
  while [ $code -gt 0 ]
  do
    eval $cmd
    code=$?

    if [[ $code -gt 0 ]]
    then
      echo $code
      echo "Wait 10 seconds, then retry"
      sleep 10
    fi
  done
}


echo "Start Source VMs"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_1" --verbose
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_NAME_IMG_SRC_2" --verbose


echo "Get source VM Resource IDs"
vm1Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_NAME_IMG_SRC_1" -o tsv --query "id")" | sed "s/\r//")
vm2Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_NAME_IMG_SRC_2" -o tsv --query "id")" | sed "s/\r//")


echo "Get source VM FQDNs"
srcVm1Fqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
srcVm2Fqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")


echo "Clean out existing source VM entries from known_hosts, if any, to avoid warnings/strict key validation fail."
ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm1Fqdn"
ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm2Fqdn"


if [ -z "$(ssh-keygen -F $srcVm1Fqdn)" ]
then
  echo "Add source VM1 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

  sshKeyScanCmd="ssh-keyscan -H ""$srcVm1Fqdn"" >> ~/.ssh/known_hosts"

  doTheSsh "$sshKeyScanCmd"
fi

if [ -z "$(ssh-keygen -F $srcVm2Fqdn)" ]
then
  echo "Add source VM2 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

  sshKeyScanCmd="ssh-keyscan -H ""$srcVm2Fqdn"" >> ~/.ssh/known_hosts"

  doTheSsh "$sshKeyScanCmd"
fi


echo "Connect to VMs, leave graffiti, delete deployment user, and execute deprovision command"
echo "NOTE - the environment where this is executed MUST have the SSH private key installed corresponding to the public key present on the VMs, else SSH login will FAIL"
sshToVm1="ssh -t $DEPLOYMENT_SSH_USER_NAME@$srcVm1Fqdn -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME" # Uses the deploy user private key set in ../02-ssh/02-create-ssh-keys-write-to-kv.ssh
sshToVm2="ssh -t $DEPLOYMENT_SSH_USER_NAME@$srcVm2Fqdn -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME" # Uses the deploy user private key set in ../02-ssh/02-create-ssh-keys-write-to-kv.ssh
remoteCmdVm="'sudo mkdir /plzm_was_here; sudo deluser --remove-home ""$DEPLOYMENT_SSH_USER_NAME""; sudo waagent -deprovision -force'" # Of course you can modify this remote cmd script to add config or install or other steps as needed before deprovisioning
fullCmdVm1="${sshToVm1} ${remoteCmdVm}"
fullCmdVm2="${sshToVm2} ${remoteCmdVm}"

doTheSsh "$fullCmdVm1"
doTheSsh "$fullCmdVm2"


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
