#!/bin/bash
set -eux

keyFilePath=~/.ssh/"$DEPLOYMENT_SSH_USER_KEY_NAME".pub
vmDeploySshPublicKey=$(<$keyFilePath)

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')" | sed "s/\r//")
fi

# Set OS disk name here so it's simple to adapt this into some sort of loop here if needed to generate many prod VMs.
osDiskName="$VM_PROD_NAME_1""-""$VM_SUFFIX_VNOW"

# Set VM tags here as we need to set the OS disk. Again, easy to adapt this into an eventual loop to generate many prod VMs.
vmTags="{\"AutoRefresh\":\"true\",\"OsDiskName\":\"""$osDiskName""\",\"Classification\":\"Production\"}"

echo "Deploy Prod VM Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM-PIP" --verbose \
	-g "$RG_NAME_VM_PROD" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_PROD_NAME_1" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_PROD_NAME_1"

echo "Deploy Prod VM Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM-NIC" --verbose \
	-g "$RG_NAME_VM_PROD" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_PROD_NAME_1" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME_PROD" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_VM_PROD" \
	publicIpName="$VM_PROD_NAME_1" \
	ipConfigName="$IP_CONFIG_NAME"

echo "Deploy Prod VM with initial OS"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM" --verbose \
	-g "$RG_NAME_VM_PROD" --template-uri "$TEMPLATE_VM" \
	--parameters \
	tags="$vmTags" \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_PROD_NAME_1" \
	virtualMachineSize="$VM_SIZE" \
	publisher="$OS_PUBLISHER_VNOW" \
	offer="$OS_OFFER_VNOW" \
	sku="$OS_SKU_VNOW" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$DEPLOYMENT_SSH_USER_NAME" \
	adminSshPublicKey="$vmDeploySshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskName="$osDiskName" \
	osDiskStorageType="$OS_DISK_STORAGE_TYPE" \
	osDiskSizeInGB="$OS_DISK_SIZE_IN_GB" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_VM_PROD" \
	networkInterfaceName="$VM_PROD_NAME_1"
