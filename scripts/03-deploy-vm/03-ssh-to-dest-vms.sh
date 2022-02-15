#!/bin/bash

echo "Retrieve VM Admin Username and SSH Public Key from Key Vault - this is NOT the deploy user, this is the actual VM admin, as this VM was deployed with a functional OS and not to just generalize to an image"
vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

# Some SSH clients will default to a local private key file name of id_rsa. You can override this with the ssh -i argument. Thus:
# ssh user@fqdn -i ~/.ssh/private_key_file
# Example: ssh myuser@myvm.eastus2.cloudapp.azure.com -i ~/.ssh/myuserprivatekeyfile

destVmFqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PIP_NAME_DEPLOY_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")

# Clean out existing FQDNs from known hosts
ssh-keygen -f ~/.ssh/known_hosts -R "$destVmFqdn"

echo "Add dest VM to SSH known hosts so that SSH login is not interrupted with interactive prompt - NOTE this may be a security concern in highly sensitive environments, ensure you are OK with this"
if [ -z "$(ssh-keygen -F $destVmFqdn)" ]; then
  ssh-keyscan -H $destVmFqdn >> ~/.ssh/known_hosts
fi

sshToVm="ssh -t $vmAdminUsername@$destVmFqdn -i ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"

remoteCmdVm="'touch i_was_here_0.txt'" # Of course you can modify this remote cmd script to add config or install or other steps as needed before deprovisioning

fullCmdVm="${sshToVm} ${remoteCmdVm}"

echo $fullCmdVm

code=1
while [ $code -gt 0 ]
do
  eval $fullCmdVm
  code=$?

  if [[ $code -gt 0 ]]
  then
    echo $code
    echo "Wait 10 seconds, then retry"
    sleep 10
  fi
done

echo "SSH done"
