#!/bin/bash

getEnvVar() {
  #Usage:
  #getEnvVar "variableName"

  varName=$1

	if [ ! -z $GITHUB_ACTIONS ]
	then
		# We are in GitHub CI environment

		envVarName=$(echo -e "\x24{{ env.""$varName"" }}")
	else
		# We are in a non-GitHub environment

		envVarName=$(echo -e "\x24""$varName")
	fi

	retVal=$(echo "echo ""$envVarName")
	eval $retVal
}

setEnvVar() {
  #Usage:
  #setEnvVar "variableName" "variableValue"

  varName=$1
  varValue=$2

	if [ ! -z $GITHUB_ACTIONS ]
	then
		# We are in GitHub CI environment
		cmd=$(echo -e "echo \x22""$varName""=""$varValue""\x22 \x3E\x3E \x24GITHUB_ENV")
	else
		# We are in a non-GitHub environment
		cmd="export ""$varName""=\"""$varValue""\""
	fi

	eval $cmd
}

# ##################################################
# NOTE - in non-GitHub environment, to work with the env vars exported herein from other files, remember to dot-source this file at the prompt!
# . ./set-env-vars.sh
# ##################################################
# Variables only for this file - not exported to env vars

azureLocation="eastus2"
subscriptionName="Sandbox"

myLocalIpAddress="75.68.47.183" # Make this blank if you don't want an NSG rule created that allows inbound traffic from this IP address

# Change this as desired. Suggest making it indicative of the VM OS publisher configured below.
osInfix="u"

resourceNamingInfix="pz"

# ARM Templates
# Use files elsewhere with az deployment group create --template-uri
templateRootUri="https://raw.githubusercontent.com/plzm/azure-deploy/main/template/"
# Use this to choose local or remote templates
templateRoot=$templateRootUri # We will use remote template files via --template-uri

# Suffixes for three VM versions - we'll deploy with 1 and prepare images for 2 and 3. Then all three will be swappable.
# This simulates starting with a deployed VM and wanting to swap between its initial OS disk and additional disks created from images.
# Here we just use suffixes for months - current, then next month, then next month after that. You can swap in your own versioning scheme.
suffixVersion1=$(date +"%Y%m")
suffixVersion2=$(date -d "+1 month" +"%Y%m")
suffixVersion3=$(date -d "+2 months" +"%Y%m")

# VM Admin user SSH public key - we assume we are provided ONLY a public key, not the private key, and that it is generated and managed outside this context.
# We use this to enable a deployed VM to be logged into and used by the user account whose public SSH key this is.
# This SSH key is not used in this context to log into the VM. It's added to the VM for eventual use by this user account.
# It's hard-coded here but of course if this is stored in the Key Vault used elsewhere here, you can just retrieve it from there at this point.
vmAdminSshUserName="pelazem"
vmAdminSshKeyName="id_rsa"
vmAdminSshPublicKeyInfix="AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw=="
vmAdminSshPublicKey="ssh-rsa ""$vmAdminSshPublicKeyInfix"" ""$vmAdminSshUserName"

deploySshUserName="deploy"
# ##################################################

# ##################################################
# SSH Key Pair for Deployment

# Deployment username - used only to deploy/configure VM
setEnvVar "DEPLOYMENT_SSH_USER_NAME" "deploy"
setEnvVar "DEPLOYMENT_SSH_USER_KEY_NAME" "id_""$deploySshUserName"
setEnvVar "DEPLOYMENT_SSH_KEY_TYPE" "rsa"
setEnvVar "DEPLOYMENT_SSH_KEY_BITS" 4096
setEnvVar "DEPLOYMENT_SSH_KEY_PASSPHRASE" "" # Use blank for convenience here as deployment SSH key will be short-lived
# DEPLOYMENT_SSH_PUBLIC_KEY # Placeholder - not set here
# DEPLOYMENT_SSH_PRIVATE_KEY # Placeholder - not set here

# VM Admin username - what a VM user would use eventually to work with a VM
setEnvVar "VM_ADMIN_SSH_USER_NAME" "$vmAdminSshUserName"
setEnvVar "VM_ADMIN_SSH_USER_KEY_NAME" "$vmAdminSshKeyName"
setEnvVar "VM_ADMIN_SSH_PUBLIC_KEY" "$vmAdminSshPublicKey"

# Key Vault Secret NAMES of the secrets whose actual VALUES you write to or retrieve from Key Vault
setEnvVar "KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME" "vm-deploy-ssh-user-name"
setEnvVar "KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" "vm-deploy-ssh-public-key"
setEnvVar "KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PRIVATE_KEY" "vm-deploy-ssh-private-key"
setEnvVar "KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" "vm-admin-ssh-user-name"
setEnvVar "KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" "vm-admin-ssh-public-key"

# ##################################################

# ##################################################
# Variables to export to env vars

setEnvVar "NSG_RULE_INBOUND_100_SRC" "$myLocalIpAddress"

# Subscription ID. bash/az cli started appending line feed so here we get rid of it.
setEnvVar "SUBSCRIPTION_ID" $(echo "$(az account show -s $subscriptionName -o tsv --query 'id')" | sed "s/\r//")

# Get Tenant ID for Subscription. Need this to create User-Assigned Managed Identity and Key Vault.
setEnvVar "TENANT_ID" $(echo "$(az account show -s $subscriptionName -o tsv --query 'tenantId')" | sed "s/\r//")

# Get current user context object ID. Need this to set initial Key Vault Access Policy so secrets etc. can be set/read in these scripts.
setEnvVar "USER_OBJECT_ID" $(echo "$(az ad signed-in-user show -o tsv --query 'objectId')" | sed "s/\r//")

# Deployment
setEnvVar "LOCATION" "eastus2"

# Resource Groups
setEnvVar "RG_NAME_SECURITY" "$resourceNamingInfix""-security-""$azureLocation"
setEnvVar "RG_NAME_SIG" "$resourceNamingInfix""-sig-""$azureLocation"
setEnvVar "RG_NAME_NET" "$resourceNamingInfix""-net-""$azureLocation"
setEnvVar "RG_NAME_SOURCE" "$resourceNamingInfix""-vm-source-""$azureLocation"
setEnvVar "RG_NAME_DEPLOY" "$resourceNamingInfix""-vm-deploy-""$azureLocation"

# User-Assigned Managed Identity
setEnvVar "USERNAME_UAMI" "$resourceNamingInfix""-vm-uami-""$azureLocation"

# Key Vault
setEnvVar "KEYVAULT_SKU_NAME" "Standard"
setEnvVar "KEYVAULT_NAME" "kv-""$resourceNamingInfix""-""$azureLocation"
setEnvVar "KEYVAULT_SOFT_DELETE" "false"

# Network
setEnvVar "NSG_NAME" "vm-nsg-""$azureLocation"
setEnvVar "VNET_NAME" "vm-vnet-""$azureLocation"
setEnvVar "VNET_PREFIX" "10.4.0.0/16"
setEnvVar "VNET_ENABLE_DDOS_PROTECTION" "Disabled" # Enabled or Disabled
setEnvVar "VNET_ENABLE_VM_PROTECTION" "Disabled" # Enabled or Disabled
setEnvVar "SUBNET_NAME" "subnet1"
setEnvVar "SUBNET_PREFIX" "10.4.1.0/24"
setEnvVar "SUBNET_SERVICE_ENDPOINTS" ""
setEnvVar "SUBNET_PRIVATE_ENDPOINT_NETWORK_POLICIES" "Enabled" # Enabled or Disabled
setEnvVar "SUBNET_PRIVATE_LINK_NETWORK_POLICIES" "Enabled" # Enabled or Disabled

# Now assemble all the individual template paths
# ARM Templates
setEnvVar "TEMPLATE_UAMI" "$templateRoot""identity.user-assigned-mi.json"
setEnvVar "TEMPLATE_KEYVAULT" "$templateRoot""key-vault.json"
setEnvVar "TEMPLATE_KEYVAULT_SECRET" "$templateRoot""key-vault.secret.json"
setEnvVar "TEMPLATE_NSG" "$templateRoot""net.nsg.json"
setEnvVar "TEMPLATE_VNET" "$templateRoot""net.vnet.json"
setEnvVar "TEMPLATE_SUBNET" "$templateRoot""net.vnet.subnet.json"
setEnvVar "TEMPLATE_PUBLIC_IP" "$templateRoot""net.public-ip.json"
setEnvVar "TEMPLATE_NIC" "$templateRoot""net.network-interface.json"
setEnvVar "TEMPLATE_VM" "$templateRoot""vm.linux.json"
setEnvVar "TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" "$templateRoot""vm.extension.custom-script.json"

# ##################################################

# VM
setEnvVar "HYPER_V_GENERATION" "V1"
setEnvVar "OS_STATE" "Generalized"

# ##################################################
# Three VM OS blocks are provided.
# All three OS disks are swappable.
# We use three OSes for the three versions here, but of course you can just use the same OS across your versions.
# I swap OSes here to also show how to vary OS offer and SKU. Totally optional, feel free to stick with your one happy OS across many image versions.
# ##################################################
# az vm image list-skus -l $LOCATION --publisher RedHat --offer RHEL -o tsv --query '[].name'
# ##################################################
setEnvVar "OS_PUBLISHER_1" "Canonical"
setEnvVar "OS_OFFER_1" "UbuntuServer"
setEnvVar "OS_SKU_1" "18.04-LTS"

setEnvVar "OS_PUBLISHER_2" "Canonical"
setEnvVar "OS_OFFER_2" "0001-com-ubuntu-server-focal"
setEnvVar "OS_SKU_2" "20_04-lts"

setEnvVar "OS_PUBLISHER_3" "Canonical"
setEnvVar "OS_OFFER_3" "0001-com-ubuntu-server-impish"
setEnvVar "OS_SKU_3" "21_10"
# ##################################################
# setEnvVar "OS_PUBLISHER_1" "RedHat"
# setEnvVar "OS_OFFER_1" "RHEL"
# setEnvVar "OS_SKU_1" "8_3"

# setEnvVar "OS_PUBLISHER_2" "RedHat"
# setEnvVar "OS_OFFER_2" "RHEL"
# setEnvVar "OS_SKU_2" "8_4"

# setEnvVar "OS_PUBLISHER_3" "RedHat"
# setEnvVar "OS_OFFER_3" "RHEL"
# setEnvVar "OS_SKU_3" "8_5"
# ##################################################

setEnvVar "VM_VERSION" "latest"

setEnvVar "VM_ENABLE_ACCELERATED_NETWORKING" "true" # This is not supported for all VM Sizes - check your VM Size!
setEnvVar "PROVISION_VM_AGENT" "true"
setEnvVar "VM_SIZE" "Standard_D4s_v3"

setEnvVar "VM_PUBLIC_IP_TYPE" "Static" # Static or Dynamic - Standard SKU requires Static
setEnvVar "VM_PUBLIC_IP_SKU" "Standard" # Basic or Standard

setEnvVar "PRIVATE_IP_ALLOCATION_METHOD" "Dynamic"
setEnvVar "IP_CONFIG_NAME" "ipConfig1"

setEnvVar "VM_TIME_ZONE" "Eastern Standard Time"

setEnvVar "OS_DISK_STORAGE_TYPE" "Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
setEnvVar "OS_DISK_SIZE_IN_GB" 64
setEnvVar "DATA_DISK_STORAGE_TYPE" "Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
setEnvVar "DATA_DISK_COUNT" 0
setEnvVar "DATA_DISK_SIZE_IN_GB" 1023
setEnvVar "VM_AUTO_SHUTDOWN_TIME" "1800"
setEnvVar "VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" "Disabled" # Disabled | Enabled
setEnvVar "VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" "" # Provide if set enableAutoShutdownNotification "Enabled"
setEnvVar "VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" 15

# Image source VMs - versions 2 and 3
setEnvVar "VM_SRC_NAME_V2" "$resourceNamingInfix""-""$osInfix""-""$suffixVersion2"
setEnvVar "VM_SRC_NAME_V3" "$resourceNamingInfix""-""$osInfix""-""$suffixVersion3"

# Deployed VMs
setEnvVar "VM_NAME_1" "$resourceNamingInfix""-""$osInfix""-1"
#setEnvVar "VM_1_OS_DISK_NAME_V1" "$VM_NAME_1""-""$suffixVersion1"
#setEnvVar "VM_1_OS_DISK_NAME_V2" "$VM_NAME_1""-""$suffixVersion2"
#setEnvVar "VM_1_OS_DISK_NAME_V3" "$VM_NAME_1""-""$suffixVersion3"
setEnvVar "VM_1_OS_DISK_NAME_V1" "$(getEnvVar "VM_NAME_1")""-""$suffixVersion1"
setEnvVar "VM_1_OS_DISK_NAME_V2" "$(getEnvVar "VM_NAME_1")""-""$suffixVersion2"
setEnvVar "VM_1_OS_DISK_NAME_V3" "$(getEnvVar "VM_NAME_1")""-""$suffixVersion3"

setEnvVar "VM_NAME_2" "$resourceNamingInfix""-""$osInfix""-2"
#setEnvVar "VM_2_OS_DISK_NAME_V1" "$VM_NAME_2""-""$suffixVersion1"
#setEnvVar "VM_2_OS_DISK_NAME_V2" "$VM_NAME_2""-""$suffixVersion2"
#setEnvVar "VM_2_OS_DISK_NAME_V3" "$VM_NAME_2""-""$suffixVersion3"
setEnvVar "VM_2_OS_DISK_NAME_V1" "$(getEnvVar "VM_NAME_2")""-""$suffixVersion1"
setEnvVar "VM_2_OS_DISK_NAME_V2" "$(getEnvVar "VM_NAME_2")""-""$suffixVersion2"
setEnvVar "VM_2_OS_DISK_NAME_V3" "$(getEnvVar "VM_NAME_2")""-""$suffixVersion3"

# Azure Compute Gallery (used to be called Shared Image Gallery but let's-rename-things-gremlins visited)
setEnvVar "SIG_NAME" "sig"
setEnvVar "VM_OS_TYPE" "Linux" # Linux | Windows
setEnvVar "VM_IMG_DEF_NAME_V2" "custom-""$osInfix""-""$(getEnvVar "OS_PUBLISHER_2")""-""$(getEnvVar "OS_OFFER_2")""-""$(getEnvVar "OS_SKU_2")""-""$suffixVersion2"
setEnvVar "VM_IMG_DEF_VERSION_V2" "1.0.0" # Could make this dynamic if, for example, generating more than one image version per image definition.
setEnvVar "VM_IMG_DEF_NAME_V3" "custom-""$osInfix""-""$(getEnvVar "OS_PUBLISHER_3")""-""$(getEnvVar "OS_OFFER_3")""-""$(getEnvVar "OS_SKU_3")""-""$suffixVersion3"
setEnvVar "VM_IMG_DEF_VERSION_V3" "1.0.0" # Could make this dynamic if, for example, generating more than one image version per image definition.

setEnvVar "VM_IMG_NAME_V2" "$(getEnvVar "VM_SRC_NAME_V2")""-image"
setEnvVar "VM_IMG_NAME_V3" "$(getEnvVar "VM_SRC_NAME_V3")""-image"
# ##################################################

echo $SIG_NAME

if [ ! -z $GITHUB_ACTIONS ]
then
	echo "We are in GitHub"
else
	echo "VM_IMG_DEF_NAME_V2 = ""$VM_IMG_DEF_NAME_V2"
	echo "VM_IMG_NAME_V2 = ""$VM_IMG_NAME_V2"
fi
