#!/bin/bash
set -eux

keyFilePath=~/.ssh/"$DEPLOYMENT_SSH_USER_KEY_NAME".pub
vmDeploySshPublicKey=$(<$keyFilePath)

echo "Public IP VM v2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-PIP-V2" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_SRC_NAME_V2" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_SRC_NAME_V2"

echo "Public IP VM v3"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-PIP-V3" --verbose \
	-g "$RG_NAME_SOURCE" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_SRC_NAME_V3" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_SRC_NAME_V3"


echo "Network Interface VM v2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-NIC-V2" --verbose \
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

echo "Network Interface VM v3"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-NIC-V3" --verbose \
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


echo "VM v2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-V2" --verbose \
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
	adminUsername="$DEPLOYMENT_SSH_USER_NAME" \
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

echo "VM v3"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-V3" --verbose \
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
	adminUsername="$DEPLOYMENT_SSH_USER_NAME" \
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
