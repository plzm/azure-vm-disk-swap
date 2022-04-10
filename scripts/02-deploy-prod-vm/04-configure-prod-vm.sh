#!/bin/bash
set -eux

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

# ##################################################

echo "Start VM"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" --name "$VM_PROD_NAME_1" --verbose

# ##################################################

echo "Get Production VM FQDNs and public IP addresses"
vmFqdn1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIp1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# ##################################################

# Prepare start of below SSH commands
sshToVmCmdStart="ssh $DEPLOYMENT_SSH_USER_NAME@$vmFqdn1 -o StrictHostKeyChecking=off -i ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"

# ##################################################

# We will run the confiuration script in remote-cmd.sh on deployed production VM next
remoteCmd=" < ./remote-cmd.sh"
sshToVmCmdFull="${sshToVmCmdStart} ${remoteCmd}"
doTheSsh "$sshToVmCmdFull"

# ##################################################

# Now we will run script to add a "real" admin user on deployed production VM
remoteCmd=" < \"../vmadmin/create-user.sh '$VM_ADMIN_SSH_USER_NAME' '$VM_ADMIN_SSH_PUBLIC_KEY'\""
sshToVmCmdFull="${sshToVmCmdStart} ${remoteCmd}"
doTheSsh "$sshToVmCmdFull"

# ##################################################

# Now we will run script to delete deployment user from deployed production VM
remoteCmd=" < ../vmadmin/delete-user.sh ""$DEPLOYMENT_SSH_USER_NAME"
sshToVmCmdFull="${sshToVmCmdStart} ${remoteCmd}"
doTheSsh "$sshToVmCmdFull"

# ##################################################
