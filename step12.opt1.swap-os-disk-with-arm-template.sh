#!/bin/bash

echo "Get the resource IDs of the OS disks"
vm3OsDiskIdVersion0="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM3_OS_DISK_NAME_1" -o tsv --query "id")"
vm3OsDiskIdVersion1="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM3_OS_DISK_NAME_2" -o tsv --query "id")"
vm3OsDiskIdVersion2="$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM3_OS_DISK_NAME_3" -o tsv --query "id")"

echo "Deallocate the existing VM so we can swap in a different OS disk"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM3_NAME" --verbose

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId="$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')"
fi

echo "Retrieve Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT was just to put them INTO Key Vault in step04.
vmAdminUsername="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_ADMIN_USERNAME" -o tsv --query 'value')"
vmAdminUserSshPublicKey="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')"

echo "VM ARM template to update the OS disk"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM3-""$LOCATION" --verbose \
	-g "$RG_NAME_DEPLOY" --template-file "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM3_NAME" \
	virtualMachineSize="$VM_SIZE" \
	publisher="$OS_PUBLISHER" \
	offer="$OS_OFFER" \
	sku="$OS_SKU_3" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskId="$vm3OsDiskIdVersion0" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_DEPLOY" \
	networkInterfaceName="$VM3_NIC_NAME"


echo "Start the VM"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM3_NAME"
