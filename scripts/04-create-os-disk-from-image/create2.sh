#!/bin/bash

#sudo apt update -y
#sudo apt-get install jq -y

myTag="Prod"

vms="$(az vm list --subscription ""$SUBSCRIPTION_ID"" --query "[?tags.Category=='""$myTag""'].{vmName:name, vmRg:resourceGroup}")"

while read -r vmName vmRg; do
	echo $vmName
	echo $vmRg
done< <(echo "${vms}" | jq -r '.[] | "\(.vmName) \(.vmRg)"')
