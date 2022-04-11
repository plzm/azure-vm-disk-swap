#!/bin/bash

# ##################################################
# IMPORTANT DO NOT SKIP THIS - READ THIS!!!!
# This script automatically generalizes the VMs. You do NOT need to do this manually. However! It is still a good idea for you to read step 1 here:
# https://docs.microsoft.com/azure/virtual-machines/linux/capture-image
# ##################################################
# NOTE The following will fail if you generalized a VM with data disks > 1023 GB. If you have data disks > 1023 GB,
# detach the data disks before generalizing and proceeding. You will need to modify later steps to detach data disks
# before OS disk swap, then swap OS disk, then re-attach large data disks.
# ##################################################

scriptdir="$(dirname "$0")"
cd "$scriptdir"

doTheSsh() {
  cmd=$1
  echo $cmd

  loop=0
  max=10
  code=9999

  while [[ $code -gt 0 && $loop -le $max ]]
  do
    loop=$((loop + 1))

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


echo "Start Source VM"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_SOURCE" --name "$VM_SRC_NAME_VNEXT" --verbose

echo "Get source VM FQDN"
vmFqdnVNext=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_SOURCE"" -n ""$VM_SRC_NAME_VNEXT"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
echo $vmFqdnVNext

echo "Connect to VM, run remote command, delete deployment user, and execute deprovision command"
echo "NOTE - the environment where this is executed MUST have the SSH private key installed corresponding to the public key present on the VMs, else SSH login will FAIL"

remoteCmd=" \"bash -s\" < ./remote-cmd.sh"

echo "vNext VM"
sshToVm="ssh -t $DEPLOYMENT_SSH_USER_NAME@$vmFqdnVNext -o StrictHostKeyChecking=off -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
fullCmdVm="${sshToVm} ${remoteCmd}"
doTheSsh "$fullCmdVm"

# ##################################################
