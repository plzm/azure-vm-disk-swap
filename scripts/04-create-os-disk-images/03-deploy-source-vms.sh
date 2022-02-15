#!/bin/bash

echo "Deploy Source VMs to use for image capture"

echo "Deploy Source VM1 Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "IMG-SRC-VM-1-PIP""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_PIP_NAME_IMG_SRC_1" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_NAME_IMG_SRC_1"

echo "Deploy Source VM2 Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "IMG-SRC-VM-2-PIP-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_PIP_NAME_IMG_SRC_2" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_NAME_IMG_SRC_2"

echo "Deploy Source VM1 Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "IMG-SRC-VM-1-NIC-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_NIC_NAME_IMG_SRC_1" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_SOURCE" \
	publicIpName="$VM_PIP_NAME_IMG_SRC_1" \
	ipConfigName="$IP_CONFIG_NAME"

echo "Deploy Source VM2 Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "IMG-SRC-VM-2-NIC-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_NIC_NAME_IMG_SRC_2" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_SOURCE" \
	publicIpName="$VM_PIP_NAME_IMG_SRC_2" \
	ipConfigName="$IP_CONFIG_NAME"


echo "Retrieve Deployment Username and SSH Public Key from Key Vault"
vmDeployUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmDeploySshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")
#echo $vmDeployUsername | cat -v
#echo $vmDeploySshPublicKey | cat -v

echo "Retrieve VM Admin Username and SSH Public Key from Key Vault"
vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")
#echo $vmAdminUsername | cat -v
#echo $vmAdminSshPublicKey | cat -v

echo "Deploy Source VM 1"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "IMG-SRC-VM-1-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_NAME_IMG_SRC_1" \
	virtualMachineSize="$VM_SIZE" \
	imageResourceId="" \
	publisher="$OS_PUBLISHER_IMG_SRC_1" \
	offer="$OS_OFFER_IMG_SRC_1" \
	sku="$OS_SKU_IMG_SRC_1" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmDeployUsername" \
	adminSshPublicKey="$vmDeploySshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskStorageType="$OS_DISK_STORAGE_TYPE" \
	osDiskSizeInGB="$OS_DISK_SIZE_IN_GB" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_SOURCE" \
	networkInterfaceName="$VM_NIC_NAME_IMG_SRC_1"

echo "Deploy Source VM 2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "IMG-SRC-VM-2-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_NAME_IMG_SRC_2" \
	virtualMachineSize="$VM_SIZE" \
	imageResourceId="" \
	publisher="$OS_PUBLISHER_IMG_SRC_2" \
	offer="$OS_OFFER_IMG_SRC_2" \
	sku="$OS_SKU_IMG_SRC_2" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmDeployUsername" \
	adminSshPublicKey="$vmDeploySshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskStorageType="$OS_DISK_STORAGE_TYPE" \
	osDiskSizeInGB="$OS_DISK_SIZE_IN_GB" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_SOURCE" \
	networkInterfaceName="$VM_NIC_NAME_IMG_SRC_2"

echo "Source VMs deployed"
