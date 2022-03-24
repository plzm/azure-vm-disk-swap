#!/bin/bash

cleanSsh() {
  entry=$1

	if [[ ! -z $entry ]]
	then
  	echo $entry
		ssh-keygen -f ~/.ssh/known_hosts -R "$entry"
	fi
}

# Get source VM FQDNs and public IP addresses
vmFqdnSourceV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_SOURCE"" -n ""$VM_SRC_NAME_VNEXT"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
VmIpSourceV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_SOURCE"" -n ""$VM_SRC_NAME_VNEXT"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdnSourceV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
VmIpSourceV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# Get prod VM FQDNs and public IP addresses
vmFqdnProd1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpProd1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

vmFqdnProd2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpProd2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# ##################################################
# Clean out existing source VM entries from known_hosts, if any, to avoid warnings/strict key validation fail.
cleanSsh $vmFqdnSourceV2
cleanSsh $VmIpSourceV2
cleanSsh $vmFqdnSourceV3
cleanSsh $VmIpSourceV3

cleanSsh $vmFqdnProd1
cleanSsh $vmIpProd1
cleanSsh $vmFqdnProd2
cleanSsh $vmIpProd2
# ##################################################
