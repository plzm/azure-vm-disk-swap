#!/bin/bash

vmFqdnPeriod1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_NAME_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpPeriod1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdnPeriod2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpPeriod2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdnPeriod3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpPeriod3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")

ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdnPeriod1"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIpPeriod1"

ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdnPeriod2"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIpPeriod2"

ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdnPeriod3"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIpPeriod3"


# Cleanup local deployment user SSH keys
sshDelCmd="ssh-add -d ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
eval $sshDelCmd
fileDelCmd="rm ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
eval $fileDelCmd
