#!/bin/bash

. ./step00.variables.sh

echo "Deploy Destination VM to use for OS disk swaps"

echo "Deploy Public IP"
az deployment group create --subscription "$subscriptionId" -n "VM3-PIP-""$location" --verbose \
	-g "$rgNameDeploy" --template-file "$templatePublicIp" \
	--parameters \
	location="$location" \
	publicIpName="$vm3PipName" \
	publicIpType="$vmPublicIpType" \
	publicIpSku="$vmPublicIpSku" \
	domainNameLabel="$vm3Name"

echo "Deploy Network Interface"
az deployment group create --subscription "$subscriptionId" -n "VM3-NIC-""$location" --verbose \
	-g "$rgNameDeploy" --template-file "$templateNetworkInterface" \
	--parameters \
	location="$location" \
	networkInterfaceName="$vm3NicName" \
	vnetResourceGroup="$rgNameNet" \
	vnetName="$vnetName" \
	subnetName="$subnetName" \
	enableAcceleratedNetworking="$enableAcceleratedNetworking" \
	privateIpAllocationMethod="$privateIpAllocationMethod" \
	publicIpResourceGroup="$rgNameDeploy" \
	publicIpName="$vm3PipName" \
	ipConfigName="$ipConfigName"

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $userNameUAMI ]
then
	uamiResourceId="$(az identity show --subscription ""$subscriptionId"" -g ""$rgNameSecurity"" --name ""$userNameUAMI"" -o tsv --query 'id')"
fi

echo "Retrieve Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT was just to put them INTO Key Vault in step04.
vmAdminUsername="$(az keyvault secret show --subscription "$subscriptionId" --vault-name "$keyVaultName" --name "$keyVaultSecretNameAdminUsername" -o tsv --query 'value')"
vmAdminUserSshPublicKey="$(az keyvault secret show --subscription "$subscriptionId" --vault-name "$keyVaultName" --name "$keyVaultSecretNameAdminSshPublicKey" -o tsv --query 'value')"

echo "Deploy VM ARM Template"
az deployment group create --subscription "$subscriptionId" -n "VM3-""$location" --verbose \
	-g "$rgNameDeploy" --template-file "$templateVirtualMachine" \
	--parameters \
	location="$location" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$vm3Name" \
	virtualMachineSize="$vmSize" \
	publisher="$vmPublisher" \
	offer="$vmOffer" \
	sku="$vm3Sku" \
	version="$vmVersion" \
	provisionVmAgent="$provisionVmAgent" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$vmTimeZone" \
	osDiskName="$vm3OsDiskNameVersion0" \
	osDiskStorageType="$osDiskStorageType" \
	osDiskSizeInGB="$osDiskSizeInGB" \
	dataDiskStorageType="$dataDiskStorageType" \
	dataDiskCount="$dataDiskCount" \
	dataDiskSizeInGB="$dataDiskSizeInGB" \
	vmAutoShutdownTime="$vmAutoShutdownTime" \
	enableAutoShutdownNotification="$enableAutoShutdownNotification" \
	autoShutdownNotificationWebhookURL="$autoShutdownNotificationWebhookURL" \
	autoShutdownNotificationMinutesBefore="$autoShutdownNotificationMinutesBefore" \
	resourceGroupNameNetworkInterface="$rgNameDeploy" \
	networkInterfaceName="$vm3NicName"

echo "Destination VM deployed"
