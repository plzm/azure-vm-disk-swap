#!/bin/bash
set -eux

# Get source VM FQDNs and public IP addresses
vmFqdnV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdnV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# ##################################################
# Clean out existing source VM entries from known_hosts, if any, to avoid warnings/strict key validation fail.
ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdnV2"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIpV2"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmFqdnV3"
ssh-keygen -f ~/.ssh/known_hosts -R "$vmIpV3"
