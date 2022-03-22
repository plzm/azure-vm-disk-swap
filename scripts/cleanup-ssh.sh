#!/bin/bash
set -eux

vmFqdn1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIp1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")
vmFqdn2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIp2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdn1"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIp1"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdn2"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIp2"

## Cleanup local deployment user SSH keys
#sshDelCmd="ssh-add -d ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
#eval $sshDelCmd
#fileDelCmd="rm ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#eval $fileDelCmd
