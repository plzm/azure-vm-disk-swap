#!/bin/bash

. ./step00.variables.sh

echo "Deploy Source VMs to use for image capture"

echo "Deploy Source VM1 Public IP"
az deployment group create --subscription "$subscriptionId" -n "VM1-PIP-""$location" --verbose \
	-g "$rgNameSource" --template-file "$templatePublicIp" \
	--parameters \
	location="$location" \
	publicIpName="$vm1PipName" \
	publicIpType="$vmPublicIpType" \
	publicIpSku="$vmPublicIpSku" \
	domainNameLabel="$vm1Name"

echo "Deploy Source VM2 Public IP"
az deployment group create --subscription "$subscriptionId" -n "VM2-PIP-""$location" --verbose \
	-g "$rgNameSource" --template-file "$templatePublicIp" \
	--parameters \
	location="$location" \
	publicIpName="$vm2PipName" \
	publicIpType="$vmPublicIpType" \
	publicIpSku="$vmPublicIpSku" \
	domainNameLabel="$vm2Name"

echo "Deploy Source VM1 Network Interface"
az deployment group create --subscription "$subscriptionId" -n "VM1-NIC-""$location" --verbose \
	-g "$rgNameSource" --template-file "$templateNetworkInterface" \
	--parameters \
	location="$location" \
	networkInterfaceName="$vm1NicName" \
	vnetResourceGroup="$rgNameNet" \
	vnetName="$vnetName" \
	subnetName="$subnetName" \
	enableAcceleratedNetworking="$enableAcceleratedNetworking" \
	privateIpAllocationMethod="$privateIpAllocationMethod" \
	publicIpResourceGroup="$rgNameSource" \
	publicIpName="$vm1PipName" \
	ipConfigName="$ipConfigName"

echo "Deploy Source VM2 Network Interface"
az deployment group create --subscription "$subscriptionId" -n "VM2-NIC-""$location" --verbose \
	-g "$rgNameSource" --template-file "$templateNetworkInterface" \
	--parameters \
	location="$location" \
	networkInterfaceName="$vm2NicName" \
	vnetResourceGroup="$rgNameNet" \
	vnetName="$vnetName" \
	subnetName="$subnetName" \
	enableAcceleratedNetworking="$enableAcceleratedNetworking" \
	privateIpAllocationMethod="$privateIpAllocationMethod" \
	publicIpResourceGroup="$rgNameSource" \
	publicIpName="$vm2PipName" \
	ipConfigName="$ipConfigName"


echo "Retrieve Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT is to put them INTO Key Vault in step04.
vmAdminUsername="$(az keyvault secret show --subscription "$subscriptionId" --vault-name "$keyVaultName" --name "$keyVaultSecretNameAdminUsername" -o tsv --query 'value')"
vmAdminUserSshPublicKey="$(az keyvault secret show --subscription "$subscriptionId" --vault-name "$keyVaultName" --name "$keyVaultSecretNameAdminSshPublicKey" -o tsv --query 'value')"

#echo $vmAdminUsername
#echo $vmAdminUserSshPublicKey

echo "Deploy Source VM1"
az deployment group create --subscription "$subscriptionId" -n "VM1-""$location" --verbose \
	-g "$rgNameSource" --template-file "$templateVirtualMachine" \
	--parameters \
	location="$location" \
	virtualMachineName="$vm1Name" \
	virtualMachineSize="$vmSize" \
	imageResourceId="" \
	publisher="$vmPublisher" \
	offer="$vmOffer" \
	sku="$vm1Sku" \
	version="$vmVersion" \
	provisionVmAgent="$provisionVmAgent" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$vmTimeZone" \
	osDiskStorageType="$osDiskStorageType" \
	osDiskSizeInGB="$osDiskSizeInGB" \
	dataDiskStorageType="$dataDiskStorageType" \
	dataDiskCount="$dataDiskCount" \
	dataDiskSizeInGB="$dataDiskSizeInGB" \
	vmAutoShutdownTime="$vmAutoShutdownTime" \
	enableAutoShutdownNotification="$enableAutoShutdownNotification" \
	autoShutdownNotificationWebhookURL="$autoShutdownNotificationWebhookURL" \
	autoShutdownNotificationMinutesBefore="$autoShutdownNotificationMinutesBefore" \
	resourceGroupNameNetworkInterface="$rgNameSource" \
	networkInterfaceName="$vm1NicName"

echo "Deploy Source VM2"
az deployment group create --subscription "$subscriptionId" -n "VM2-""$location" --verbose \
	-g "$rgNameSource" --template-file "$templateVirtualMachine" \
	--parameters \
	location="$location" \
	virtualMachineName="$vm2Name" \
	virtualMachineSize="$vmSize" \
	imageResourceId="" \
	publisher="$vmPublisher" \
	offer="$vmOffer" \
	sku="$vm2Sku" \
	version="$vmVersion" \
	provisionVmAgent="$provisionVmAgent" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$vmTimeZone" \
	osDiskStorageType="$osDiskStorageType" \
	osDiskSizeInGB="$osDiskSizeInGB" \
	dataDiskStorageType="$dataDiskStorageType" \
	dataDiskCount="$dataDiskCount" \
	dataDiskSizeInGB="$dataDiskSizeInGB" \
	vmAutoShutdownTime="$vmAutoShutdownTime" \
	enableAutoShutdownNotification="$enableAutoShutdownNotification" \
	autoShutdownNotificationWebhookURL="$autoShutdownNotificationWebhookURL" \
	autoShutdownNotificationMinutesBefore="$autoShutdownNotificationMinutesBefore" \
	resourceGroupNameNetworkInterface="$rgNameSource" \
	networkInterfaceName="$vm2NicName"

echo "Source VMs deployed"