#!/bin/bash
set -eu

echo "List VMs with tag AutoRefresh=true and whose tag OsDiskName does not end with $VM_SUFFIX_VNEXT. These are targets for re-tagging to OsDiskName=$VM_SUFFIX_VNEXT."

query="Resources | where type =~ \"microsoft.compute/virtualmachines\" and tags['AutoRefresh'] =~ \"true\" and not(tags['OsDiskName'] endswith_cs \"""$VM_SUFFIX_VNEXT""\") | project id, name"

vms="$(az graph query -q "$query" --subscription "$SUBSCRIPTION_ID" --query 'data[].{id:id, name:name}')"

while read -r id name location resourceGroup
do
	tagValue="$name""-""$VM_SUFFIX_VNEXT"

	echo "Update VM ""$id"" OsDiskName tag to ""$tagValue"
	az tag update --subscription "$SUBSCRIPTION_ID" --resource-id "$id" --operation Merge --tags OsDiskName="$tagValue"

done< <(echo "${vms}" | jq -r '.[] | "\(.id) \(.name)"')
