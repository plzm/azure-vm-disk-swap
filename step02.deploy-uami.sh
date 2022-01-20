#!/bin/bash

. ./step00.variables.sh

if [ ! -z $userNameUAMI ]
then
	echo "Create User-Assigned Managed Identity"
	az deployment group create --subscription "$subscriptionId" -n "UAMI-""$location" --verbose \
		-g "$rgNameSecurity" --template-uri "$templateUami" \
		--parameters \
		location="$location" \
		tenantId="$tenantId" \
		identityName="$userNameUAMI"

	#Debug
	#identityResourceId="$(az identity show --subscription ""$subscriptionId"" -g ""$rgNameSecurity"" --name ""$userNameUAMI"" -o tsv --query 'id')"
	#echo $identityResourceId
fi
