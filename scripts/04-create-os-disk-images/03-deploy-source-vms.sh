#!/bin/bash

echo "Retrieve Deployment Username and SSH Public Key from Key Vault"
vmDeployUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmDeploySshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")
#echo $vmDeployUsername | cat -v
#echo $vmDeploySshPublicKey | cat -v


echo "Deploy Source VMs to use for image capture"

echo "Source VM for period 2"
echo "Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-PIP-P2" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_SRC_NAME_V2" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_SRC_NAME_V2"

echo "Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-NIC-P2" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_SRC_NAME_V2" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_SOURCE" \
	publicIpName="$VM_SRC_NAME_V2" \
	ipConfigName="$IP_CONFIG_NAME"

echo "VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-P2" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_SRC_NAME_V2" \
	virtualMachineSize="$VM_SIZE" \
	imageResourceId="" \
	publisher="$OS_PUBLISHER_2" \
	offer="$OS_OFFER_2" \
	sku="$OS_SKU_2" \
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
	networkInterfaceName="$VM_SRC_NAME_V2"


echo "Source VM for period 3"
echo "Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-PIP-P3" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_SRC_NAME_V3" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_SRC_NAME_V3"

echo "Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-NIC-P3" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_SRC_NAME_V3" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_SOURCE" \
	publicIpName="$VM_SRC_NAME_V3" \
	ipConfigName="$IP_CONFIG_NAME"

echo "VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-P3" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_SRC_NAME_V3" \
	virtualMachineSize="$VM_SIZE" \
	imageResourceId="" \
	publisher="$OS_PUBLISHER_3" \
	offer="$OS_OFFER_3" \
	sku="$OS_SKU_3" \
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
	networkInterfaceName="$VM_SRC_NAME_V3"

echo "Source VMs deployed"
