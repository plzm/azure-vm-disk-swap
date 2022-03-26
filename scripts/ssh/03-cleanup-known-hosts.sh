#!/bin/bash

cleanSsh() {
  entry=$1

	if [[ ! -z $entry ]]
	then
  	echo $entry
		ssh-keygen -f ~/.ssh/known_hosts -R "$entry"
	fi
}

# Get source VM FQDN and public IP address
vmFqdnSource=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_SOURCE"" -n ""$VM_SRC_NAME_VNEXT"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
VmIpSource=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_SOURCE"" -n ""$VM_SRC_NAME_VNEXT"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# Get prod VM FQDN and public IP address
vmFqdnProd=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'dnsSettings.fqdn')" | sed "s/\r//")
vmIpProd=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")

# ##################################################
# Clean out existing source VM entries from known_hosts, if any, to avoid warnings/strict key validation fail.
cleanSsh $vmFqdnSource
cleanSsh $VmIpSource

cleanSsh $vmFqdnProd
cleanSsh $vmIpProd
# ##################################################
