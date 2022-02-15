#!/bin/bash

# Some SSH clients will default to a local private key file name of id_rsa. You can override this with the ssh -i argument. Thus:
# ssh user@fqdn -i ~/.ssh/private_key_file
# Example: ssh myuser@myvm.eastus2.cloudapp.azure.com -i ~/.ssh/myuserprivatekeyfile

srcVm1Fqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
srcVm2Fqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")

echo "Clean out existing source VM entries from known_hosts, if any, to avoid warnings/strict key validation fail."
ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm1Fqdn"
ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm2Fqdn"

echo "Add source VM1 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"
if [ -z "$(ssh-keygen -F $srcVm1Fqdn)" ]; then
  ssh-keyscan -H $srcVm1Fqdn >> ~/.ssh/known_hosts
fi

echo "Add source VM2 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"
if [ -z "$(ssh-keygen -F $srcVm2Fqdn)" ]; then
  ssh-keyscan -H $srcVm2Fqdn >> ~/.ssh/known_hosts
fi

sshToVm1="ssh -t $DEPLOYMENT_SSH_USER_NAME@$srcVm1Fqdn -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME" # Uses the deploy user private key set in ../02-ssh/02-create-ssh-keys-write-to-kv.ssh
sshToVm2="ssh -t $DEPLOYMENT_SSH_USER_NAME@$srcVm2Fqdn -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME" # Uses the deploy user private key set in ../02-ssh/02-create-ssh-keys-write-to-kv.ssh

remoteCmdVm1="'touch i_was_here_1.txt'" # Of course you can modify this remote cmd script to add config or install or other steps as needed before deprovisioning
remoteCmdVm2="'touch i_was_here_2.txt'" # Of course you can modify this remote cmd script to add config or install or other steps as needed before deprovisioning

fullCmdVm1="${sshToVm1} ${remoteCmdVm1}"
fullCmdVm2="${sshToVm2} ${remoteCmdVm2}"

doTheSsh "VM1" "$fullCmdVm1"
doTheSsh "VM2" "$fullCmdVm2"

doTheSsh() {
  vmName=$1
  cmd=$2

  echo $vmName
  echo $cmd

  code=1
  while [ $code -gt 0 ]
  do
    eval $1
    code=$?

    if [[ $code -gt 0 ]]
    then
      echo $code
      echo "Wait 10 seconds, then retry"
      sleep 10
    fi
  done

  echo "SSH to ""$vmName"" done"
}


