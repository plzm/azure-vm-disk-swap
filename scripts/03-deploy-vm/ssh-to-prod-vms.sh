#!/bin/bash
set -eux

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

echo "Start Destination VMs"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_1" --verbose
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_2" --verbose

# Some SSH clients will default to a local private key file name of id_rsa. You can override this with the ssh -i argument. Thus:
# ssh user@fqdn -i ~/.ssh/private_key_file
# Example: ssh myuser@myvm.eastus2.cloudapp.azure.com -i ~/.ssh/myuserprivatekeyfile

vmFqdn1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_NAME_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIp1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdn2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_NAME_2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIp2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_NAME_2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# Clean out existing FQDNs and public IPs from known hosts
ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdn1"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIp1"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdn2"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIp2"

if [ -z "$(ssh-keygen -F $vmFqdn1)" ]
then
  echo "Add VM 1 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

  sshKeyScanCmd="ssh-keyscan -H ""$vmFqdn1"" >> ~/.ssh/known_hosts"

  doTheSsh "$sshKeyScanCmd"
fi

if [ -z "$(ssh-keygen -F $vmFqdn2)" ]
then
  echo "Add VM 2 to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"

  sshKeyScanCmd="ssh-keyscan -H ""$vmFqdn2"" >> ~/.ssh/known_hosts"

  doTheSsh "$sshKeyScanCmd"
fi

# We will run the script in remote-cmd.sh on each deployed VM next
remoteCmd=" < remote-cmd.sh"

sshToVm1="ssh -t $VM_ADMIN_SSH_USER_NAME@$vmFqdn1 -i ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"
fullCmdVm1="${sshToVm1} ${remoteCmd}"
doTheSsh "$fullCmdVm1"

sshToVm2="ssh -t $VM_ADMIN_SSH_USER_NAME@$vmFqdn2 -i ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"
fullCmdVm2="${sshToVm2} ${remoteCmd}"
doTheSsh "$fullCmdVm2"

