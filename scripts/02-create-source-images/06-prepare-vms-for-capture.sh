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


echo "Start Source VMs"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V2" --verbose
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --name "$VM_SRC_NAME_V3" --verbose

echo "Get source VM FQDNs and public IP addresses"
vmFqdnV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdnV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")

#echo $vmFqdnV2
#echo $vmIpV2
#echo $vmFqdnV3
#echo $vmIpV3

if [[ ! -d "~/.ssh" ]]
then
  echo "Create ~/.ssh directory"
  mkdir -p ~/.ssh
fi

if [[ ! -z $GITHUB_ACTIONS ]]
then
  echo "We are in GitHub CI environment - create SSH config file to avoid SSH login being interrupted with key prompt"

  configFile="Host ""$vmFqdnV2"" ""$vmFqdnV3""\n
  User ""$DEPLOYMENT_SSH_USER_NAME""\n
  IdentityFile ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""\n
  StrictHostKeyChecking no\n"

  echo -e $configFile > "~/.ssh/config"
fi

if [[ ! -f "~/.ssh/known_hosts" ]]
then
  echo "Create new known_hosts file"
  touch ~/.ssh/known_hosts
  chmod 644 ~/.ssh/known_hosts
else
  echo "Clean out existing source VM entries from known_hosts, if any, to avoid warnings/strict key validation fail."
  ssh-keygen -v -f ~/.ssh/known_hosts -R "$vmFqdnV2"
  ssh-keygen -v -f ~/.ssh/known_hosts -R "$vmIpV2"
  ssh-keygen -v -f ~/.ssh/known_hosts -R "$vmFqdnV3"
  ssh-keygen -v -f ~/.ssh/known_hosts -R "$vmIpV3"
fi

# ##################################################


#if [[ -z "$(ssh-keygen -v -F $vmFqdnV2)" ]]
#then
#  echo "Add v2 VM to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

#  sshKeyScanCmd="ssh-keyscan -v -H ""$vmFqdnV2"

#  doTheSsh "$sshKeyScanCmd"
#fi

#if [[ -z "$(ssh-keygen -v -F $vmFqdnV3)" ]]
#then
#  echo "Add v3 VM to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

#  sshKeyScanCmd="ssh-keyscan -v -H ""$vmFqdnV3"" >> ~/.ssh/known_hosts"

#  doTheSsh "$sshKeyScanCmd"
#fi
# ##################################################


## ##################################################
#echo "Connect to VMs, run remote command, delete deployment user, and execute deprovision command"
#echo "NOTE - the environment where this is executed MUST have the SSH private key installed corresponding to the public key present on the VMs, else SSH login will FAIL"

#remoteCmd=" < remote-cmd.sh"

#echo "V2 VM"
#sshToVmV2="ssh -v -t $DEPLOYMENT_SSH_USER_NAME@$vmFqdnV2 -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
#fullCmdVmV2="${sshToVmV2} ${remoteCmd}"
#doTheSsh "$fullCmdVmV2"

#echo "V3 VM"
#sshToVmV3="ssh -v -t $DEPLOYMENT_SSH_USER_NAME@$vmFqdnV3 -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
#fullCmdVmV3="${sshToVmV3} ${remoteCmd}"
#doTheSsh "$fullCmdVmV3"
## ##################################################
