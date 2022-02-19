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
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V2" --verbose
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V3" --verbose


echo "Get source VM Resource IDs"
vm1Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_SRC_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
vm2Id=$(echo "$(az vm show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" -n "$VM_SRC_NAME_V3" -o tsv --query "id")" | sed "s/\r//")


echo "Get source VM FQDNs and public IP addresses"
vmFqdnPeriod2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpPeriod2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdnPeriod3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpPeriod3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")


# ##################################################
echo "Clean out existing source VM entries from known_hosts, if any, to avoid warnings/strict key validation fail."
ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdnPeriod2"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIpPeriod2"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdnPeriod3"
ssh-keygen -f ~/.ssh/known_hosts -R "$vvmIpPeriod3"


if [ -z "$(ssh-keygen -F $vmFqdnPeriod2)" ]
then
  echo "Add source VM1 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

  sshKeyScanCmd="ssh-keyscan -H ""$vmFqdnPeriod2"" >> ~/.ssh/known_hosts"

  doTheSsh "$sshKeyScanCmd"
fi

if [ -z "$(ssh-keygen -F $vmFqdnPeriod3)" ]
then
  echo "Add source VM2 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

  sshKeyScanCmd="ssh-keyscan -H ""$vmFqdnPeriod3"" >> ~/.ssh/known_hosts"

  doTheSsh "$sshKeyScanCmd"
fi
# ##################################################


# ##################################################
echo "Connect to VMs, leave graffiti, delete deployment user, and execute deprovision command"
echo "NOTE - the environment where this is executed MUST have the SSH private key installed corresponding to the public key present on the VMs, else SSH login will FAIL"
sshToVm1="ssh -t $DEPLOYMENT_SSH_USER_NAME@$vmFqdnPeriod2 -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME" # Uses the deploy user private key set in ../02-ssh/02-create-ssh-keys-write-to-kv.ssh
sshToVm2="ssh -t $DEPLOYMENT_SSH_USER_NAME@$vmFqdnPeriod3 -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME" # Uses the deploy user private key set in ../02-ssh/02-create-ssh-keys-write-to-kv.ssh
remoteCmdVm="'touch i_was_here.txt; sudo mkdir /plzm_was_here; sudo chown -R root:root /plzm_was_here; sudo waagent -deprovision+user -force'" # Of course you can modify this remote cmd script to add config or install or other steps as needed before deprovisioning # sudo deluser --force --remove-home ""$DEPLOYMENT_SSH_USER_NAME""; 
fullCmdVm1="${sshToVm1} ${remoteCmdVm}"
fullCmdVm2="${sshToVm2} ${remoteCmdVm}"

echo "Prepare VM1"
doTheSsh "$fullCmdVm1"
echo ""
echo "Prepare VM2"
doTheSsh "$fullCmdVm2"
# ##################################################
