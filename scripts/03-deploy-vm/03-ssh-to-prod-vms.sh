#!/bin/bash

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

echo "Retrieve VM Admin Username and SSH Public Key from Key Vault - this is NOT the deploy user, this is the actual VM admin, as this VM was deployed with a functional OS and not to just generalize to an image"
vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

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

remoteCmdVm="'touch plzm.txt; sudo mkdir /plzm_was_here;'" # Of course you can modify this remote cmd script to add config or install or other steps as needed before deprovisioning

sshToVm1="ssh -t $vmAdminUsername@$vmFqdn1 -i ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"
fullCmdVm1="${sshToVm1} ${remoteCmdVm}"
doTheSsh "$fullCmdVm1"

sshToVm2="ssh -t $vmAdminUsername@$vmFqdn2 -i ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"
fullCmdVm2="${sshToVm2} ${remoteCmdVm}"
doTheSsh "$fullCmdVm2"
