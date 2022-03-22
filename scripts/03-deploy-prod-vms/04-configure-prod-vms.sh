#!/bin/bash
set -eux

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

# ##################################################

echo "Start Production VMs"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_1" --verbose
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_2" --verbose

# ##################################################

echo "Get Production VM FQDNs and public IP addresses"
vmFqdn1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIp1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdn2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIp2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# We will run the script in remote-cmd.sh on each deployed production VM next
remoteCmd=" < ./scripts/03-deploy-prod-vms/remote-cmd.sh"

# ##################################################

echo "NOTE wherever you run this, you MUST have the admin user PRIVATE key file available, named ""$VM_ADMIN_SSH_USER_KEY_NAME"
echo "A GitHub-hosted runner will NOT have this by default unless YOU have provided for it to be there"

sshToVm1="ssh -t $VM_ADMIN_SSH_USER_NAME@$vmFqdn1 -o StrictHostKeyChecking=off -i ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"
fullCmdVm1="${sshToVm1} ${remoteCmd}"
doTheSsh "$fullCmdVm1"

sshToVm2="ssh -t $VM_ADMIN_SSH_USER_NAME@$vmFqdn2 -o StrictHostKeyChecking=off -i ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME"
fullCmdVm2="${sshToVm2} ${remoteCmd}"
doTheSsh "$fullCmdVm2"

# ##################################################

echo "Deallocate Production VMs"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_1" --verbose
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_2" --verbose

# ##################################################
