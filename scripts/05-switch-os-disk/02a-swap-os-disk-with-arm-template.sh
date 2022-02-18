#!/bin/bash

echo "Get the resource IDs of the OS disks"
vmOsDiskId1=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_DEPLOY_1_OS_DISK_NAME_1" -o tsv --query "id")" | sed "s/\r//")
vmOsDiskId2=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_DEPLOY_1_OS_DISK_NAME_2" -o tsv --query "id")" | sed "s/\r//")
vmOsDiskId3=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_DEPLOY_1_OS_DISK_NAME_3" -o tsv --query "id")" | sed "s/\r//")

echo "Set the resource ID of the OS disk to swap TO"
newVmOsDiskId=$vmOsDiskId2

echo "Deallocate the existing VM so we can swap in a different OS disk"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_DEPLOY_1" --verbose

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')" | sed "s/\r//")
fi

echo "Retrieve Admin Username and SSH Public Key from Key Vault"
vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminUserSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

echo "VM ARM template to update the OS disk"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$VM_NAME_DEPLOY_1""-OS-DISK" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_NAME_DEPLOY_1" \
	virtualMachineSize="$VM_SIZE" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskId="$newVmOsDiskId" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_DEPLOY" \
	networkInterfaceName="$VM_NIC_NAME_DEPLOY_1"

echo "Start the VM"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM_NAME_DEPLOY_1"
