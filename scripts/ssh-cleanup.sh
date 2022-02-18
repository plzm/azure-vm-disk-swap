#!/bin/bash

srcVm1Fqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
srcVm1PublicIpAddress=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

srcVm2Fqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
srcVm2PublicIpAddress=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_PIP_NAME_IMG_SRC_2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

destVmFqdn=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PIP_NAME_DEPLOY_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
destVmPublicIpAddress=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_DEPLOY"" -n ""$VM_PIP_NAME_DEPLOY_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm1Fqdn"
ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm1PublicIpAddress"

ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm2Fqdn"
ssh-keygen -f ~/.ssh/known_hosts -R "$srcVm2PublicIpAddress"

ssh-keygen -f ~/.ssh/known_hosts -R "$destVmFqdn"
ssh-keygen -f ~/.ssh/known_hosts -R "$destVmPublicIpAddress"


# Cleanup local deployment user SSH keys
sshDelCmd="ssh-add -d ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
eval $sshDelCmd
fileDelCmd="rm ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
eval $fileDelCmd
