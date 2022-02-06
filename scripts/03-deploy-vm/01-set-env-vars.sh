#!/bin/bash

# ##################################################
# Variables only for this file - not exported to env vars

subscriptionName="Sandbox"

# The actual SSH key part - for convenience, using this in public keys for both deploy admin user as well as the new admin user
# that will be created on new VM post-deploy (see step 13)
sshPublicKeyInfix="AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw=="

# Change this as desired. Suggest making it indicative of the VM OS publisher configured below.
osInfix="u"

resourceNamingInfix="pz"

# ARM Templates
# Use local files with az deployment group create --template-file
templateRootLocal="../../template/"
# Use files elsewhere with az deployment group create --template-uri
templateRootUri="https://raw.githubusercontent.com/plzm/azure-deploy/main/template/"
# Use this to choose local or remote templates
templateRoot=$templateRootUri # We will use remote template files via --template-uri

# ##################################################

# ##################################################
# Variables to export to env vars

# Provide at least these values
# Initial admin username
export ADMIN_USER_NAME="pelazem"
# New admin user to be added to VM in step13
export NEW_ADMIN_USER_NAME="newAdmin"

# In the form single-line, 'ssh-rsa key== username'
# Public SSH key for initial admin user
export ADMIN_SSH_PUBLIC_KEY="ssh-rsa ""$sshPublicKeyInfix"" ""$ADMIN_USER_NAME"

# In the form single-line, 'ssh-rsa key== username'
# Public SSH key for new admin user for step 13
# For convenience, re-using the same public key as above for initial deploy user... you will likely want to set a different public SSH key per user.
export NEW_ADMIN_SSH_PUBLIC_KEY="ssh-rsa ""$sshPublicKeyInfix"" ""$NEW_ADMIN_USER_NAME"

# Subscription ID. bash/az cli started appending line feed so here we get rid of it.
export SUBSCRIPTION_ID=$(echo "$(az account show -s $subscriptionName -o tsv --query 'id')" | sed "s/\r//")

# Deployment
export LOCATION="eastus2"

# Resource Groups
export RG_NAME_DEPLOY="$resourceNamingInfix""-vm-deploy-""$LOCATION"

# User-Assigned Managed Identity
export USERNAME_UAMI="$resourceNamingInfix""-vm-uami-""$LOCATION"

# Key Vault
export KEYVAULT_NAME="kv-""$resourceNamingInfix""-""$LOCATION"
export KEYVAULT_SECRET_NAME_ADMIN_USERNAME="vmAdminUsername"
export KEYVAULT_SECRET_NAME_ADMIN_SSH_PUBLIC_KEY="vmAdminSshPublicKey"
export KEYVAULT_SECRET_NAME_NEW_ADMIN_USERNAME="vmNewAdminUsername"
export KEYVAULT_SECRET_NAME_NEW_ADMIN_SSH_PUBLIC_KEY="vmNewAdminSshPublicKey"

# Network
export VNET_NAME="vm-test-vnet-""$LOCATION"
export SUBNET_NAME="subnet1"

# Now assemble all the individual template paths
# ARM Templates
export TEMPLATE_KEYVAULT_SECRET="$templateRoot""key-vault.secret.json"
export TEMPLATE_PUBLIC_IP="$templateRoot""net.public-ip.json"
export TEMPLATE_NIC="$templateRoot""net.network-interface.json"
export TEMPLATE_VM="$templateRoot""vm.linux.json"
export TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT="$templateRoot""vm.extension.custom-script.json"

# VM
export HYPER_V_GENERATION="V1"
export OS_STATE="Generalized"

# ##################################################
# Three VM OS blocks are provided.
# All three OS disks are swappable.
# ##################################################
export OS_PUBLISHER_DEPLOY_1="Canonical"
export OS_OFFER_DEPLOY_1="UbuntuServer"
export OS_SKU_DEPLOY_1="18.04-LTS"

export OS_PUBLISHER_IMG_SRC_1="Canonical"
export OS_OFFER_IMG_SRC_1="0001-com-ubuntu-server-focal"
export OS_SKU_IMG_SRC_1="20_04-lts"

export OS_PUBLISHER_IMG_SRC_2="Canonical"
export OS_OFFER_IMG_SRC_2="0001-com-ubuntu-server-impish"
export OS_SKU_IMG_SRC_2="21_10"
# ##################################################
# az vm image list-skus -l $LOCATION --publisher RedHat --offer RHEL -o tsv --query '[].name'
#export OS_PUBLISHER_DEPLOY_1="RedHat"
#export OS_OFFER_DEPLOY_1="RHEL"
#export OS_SKU_DEPLOY_1="8_3"

#export OS_PUBLISHER_IMG_SRC_1="RedHat"
#export OS_OFFER_IMG_SRC_1="RHEL"
#export OS_SKU_IMG_SRC_1="8_4"

#export OS_PUBLISHER_IMG_SRC_2="RedHat"
#export OS_OFFER_IMG_SRC_2="RHEL"
#export OS_SKU_IMG_SRC_2="8_5"
# ##################################################

export VM_VERSION="latest"

export VM_ENABLE_ACCELERATED_NETWORKING="true" # This is not supported for all VM Sizes - check your VM Size!
export PROVISION_VM_AGENT="true"
export VM_SIZE="Standard_D4s_v3"

export VM_PUBLIC_IP_TYPE="Dynamic" # Static or Dynamic - Standard SKU requires Static
export VM_PUBLIC_IP_SKU="Basic" # Basic or Standard

export PRIVATE_IP_ALLOCATION_METHOD="Dynamic"
export IP_CONFIG_NAME="ipConfig1"

export VM_TIME_ZONE="Eastern Standard Time"

export OS_DISK_STORAGE_TYPE="Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
export OS_DISK_SIZE_IN_GB=64
export DATA_DISK_STORAGE_TYPE="Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
export DATA_DISK_COUNT=0
export DATA_DISK_SIZE_IN_GB=1023
export VM_AUTO_SHUTDOWN_TIME="1800"
export VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION="Disabled" # Disabled | Enabled
export VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL="" # Provide if set enableAutoShutdownNotification="Enabled"
export VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE=15

# OS upgrade source VMs
export VM_NAME_IMG_SRC_1="$resourceNamingInfix""-""$osInfix""-src-1"
export VM_NAME_IMG_SRC_2="$resourceNamingInfix""-""$osInfix""-src-2"
export VM_PIP_NAME_IMG_SRC_1="$VM_NAME_IMG_SRC_1""-pip"
export VM_PIP_NAME_IMG_SRC_2="$VM_NAME_IMG_SRC_2""-pip"
export VM_NIC_NAME_IMG_SRC_1="$VM_NAME_IMG_SRC_1""-nic"
export VM_NIC_NAME_IMG_SRC_2="$VM_NAME_IMG_SRC_2""-nic"

# Initial deployed VM
export VM_NAME_DEPLOY_1="$resourceNamingInfix""-""$osInfix""-dep-1"
export VM_PIP_NAME_DEPLOY_1="$VM_NAME_DEPLOY_1""-pip"
export VM_NIC_NAME_DEPLOY_1="$VM_NAME_DEPLOY_1""-nic"
export VM_DEPLOY_1_OS_DISK_NAME_1="$VM_NAME_DEPLOY_1""-os-""$OS_PUBLISHER_DEPLOY_1""-""$OS_OFFER_DEPLOY_1""-""$OS_SKU_DEPLOY_1"
export VM_DEPLOY_1_OS_DISK_NAME_2="$VM_NAME_DEPLOY_1""-os-""$OS_PUBLISHER_IMG_SRC_1""-""$OS_OFFER_IMG_SRC_1""-""$OS_SKU_IMG_SRC_1"
export VM_DEPLOY_1_OS_DISK_NAME_3="$VM_NAME_DEPLOY_1""-os-""$OS_PUBLISHER_IMG_SRC_2""-""$OS_OFFER_IMG_SRC_2""-""$OS_SKU_IMG_SRC_2"

#SIG
export VM_OS_TYPE="Linux" # Linux | Windows
export VM_IMG_DEFINITION_IMG_SRC_1="custom-""$osInfix""-""$OS_PUBLISHER_IMG_SRC_1""-""$OS_OFFER_IMG_SRC_1""-""$OS_SKU_IMG_SRC_1"
export VM_IMG_VERSION_IMG_SRC_1="1.0.0" # Can make this dynamic, maybe tied to date? Instead of hard-coding.
export VM_IMG_DEFINITION_IMG_SRC_2="custom-""$osInfix""-""$OS_PUBLISHER_IMG_SRC_2""-""$OS_OFFER_IMG_SRC_2""-""$OS_SKU_IMG_SRC_2"
export VM_IMG_VERSION_IMG_SRC_2="1.0.0" # Can make this dynamic, maybe tied to date? Instead of hard-coding.

export VM_IMG_NAME_IMG_SRC_1="$VM_NAME_IMG_SRC_1""-image"
export VM_IMG_NAME_IMG_SRC_2="$VM_NAME_IMG_SRC_2""-image"
# ##################################################
