#!/bin/bash

. ./step00.variables.sh

echo "Get the resource IDs of the OS disks"
vm3OsDiskIdVersion0="$(az disk show --subscription "$subscriptionId" -g "$rgNameDeploy" -n "$vm3OsDiskNameVersion0" -o tsv --query "id")"
vm3OsDiskIdVersion1="$(az disk show --subscription "$subscriptionId" -g "$rgNameDeploy" -n "$vm3OsDiskNameVersion1" -o tsv --query "id")"
vm3OsDiskIdVersion2="$(az disk show --subscription "$subscriptionId" -g "$rgNameDeploy" -n "$vm3OsDiskNameVersion2" -o tsv --query "id")"

echo "Deallocate the existing VM so we can swap in a different OS disk"
az vm deallocate --subscription "$subscriptionId" -g "$rgNameDeploy" --name "$vm3Name" --verbose

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $userNameUAMI ]
then
	uamiResourceId="$(az identity show --subscription ""$subscriptionId"" -g ""$rgNameSecurity"" --name ""$userNameUAMI"" -o tsv --query 'id')"
fi

echo "Retrieve Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT was just to put them INTO Key Vault in step04.
vmAdminUsername="$(az keyvault secret show --subscription "$subscriptionId" --vault-name "$keyVaultName" --name "$keyVaultSecretNameAdminUsername" -o tsv --query 'value')"
vmAdminUserSshPublicKey="$(az keyvault secret show --subscription "$subscriptionId" --vault-name "$keyVaultName" --name "$keyVaultSecretNameAdminSshPublicKey" -o tsv --query 'value')"

echo "VM ARM template to update the OS disk"
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
	osDiskId="$vm3OsDiskIdVersion0" \
	dataDiskStorageType="$dataDiskStorageType" \
	dataDiskCount="$dataDiskCount" \
	dataDiskSizeInGB="$dataDiskSizeInGB" \
	vmAutoShutdownTime="$vmAutoShutdownTime" \
	enableAutoShutdownNotification="$enableAutoShutdownNotification" \
	autoShutdownNotificationWebhookURL="$autoShutdownNotificationWebhookURL" \
	autoShutdownNotificationMinutesBefore="$autoShutdownNotificationMinutesBefore" \
	resourceGroupNameNetworkInterface="$rgNameDeploy" \
	networkInterfaceName="$vm3NicName"


echo "Start the VM"
az vm start --subscription "$subscriptionId" -g "$rgNameDeploy" --verbose \
	-n "$vm3Name"
