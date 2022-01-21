#!/bin/bash

echo "Deploy Source VMs to use for image capture"

echo "Deploy Source VM1 Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM1-PIP-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-file "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM1_PIP_NAME" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM1_NAME"

echo "Deploy Source VM2 Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM2-PIP-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-file "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM2_PIP_NAME" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM2_NAME"

echo "Deploy Source VM1 Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM1-NIC-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-file "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM1_NIC_NAME" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_SOURCE" \
	publicIpName="$VM1_PIP_NAME" \
	ipConfigName="$IP_CONFIG_NAME"

echo "Deploy Source VM2 Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM2-NIC-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-file "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM2_NIC_NAME" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_SOURCE" \
	publicIpName="$VM2_PIP_NAME" \
	ipConfigName="$IP_CONFIG_NAME"


echo "Retrieve Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT is to put them INTO Key Vault in step04.
vmAdminUsername="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_ADMIN_USERNAME" -o tsv --query 'value')"
vmAdminUserSshPublicKey="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')"

#echo $vmAdminUsername
#echo $vmAdminUserSshPublicKey

echo "Deploy Source VM1"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM1-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-file "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM1_NAME" \
	virtualMachineSize="$VM_SIZE" \
	imageResourceId="" \
	publisher="$OS_PUBLISHER" \
	offer="$OS_OFFER" \
	sku="$OS_SKU_1" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
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
	networkInterfaceName="$VM1_NIC_NAME"

echo "Deploy Source VM2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM2-""$LOCATION" --verbose \
	-g "$RG_NAME_SOURCE" --template-file "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM2_NAME" \
	virtualMachineSize="$VM_SIZE" \
	imageResourceId="" \
	publisher="$OS_PUBLISHER" \
	offer="$OS_OFFER" \
	sku="$OS_SKU_2" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
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
	networkInterfaceName="$VM2_NIC_NAME"

echo "Source VMs deployed"