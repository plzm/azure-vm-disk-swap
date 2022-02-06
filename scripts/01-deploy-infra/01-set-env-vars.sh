#!/bin/bash

# NOTE - to work with the env vars exported herein from other files, remember to dot-source this file at the prompt!
# . ./01-set-env-vars.sh

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
export NSG_RULE_INBOUND_100_SRC="75.68.47.183" # Leave empty to not add an inbound NSG rule for dev/test - see the net.nsg template
# Initial admin username
export ADMIN_USER_NAME="pelazem"

# In the form single-line, 'ssh-rsa key== username'
# Public SSH key for initial admin user
export ADMIN_SSH_PUBLIC_KEY="ssh-rsa ""$sshPublicKeyInfix"" ""$ADMIN_USER_NAME"

# Subscription ID. bash/az cli started appending line feed so here we get rid of it.
export SUBSCRIPTION_ID=$(echo "$(az account show -s $subscriptionName -o tsv --query 'id')" | sed "s/\r//")

# Get Tenant ID for Subscription. Need this to create User-Assigned Managed Identity and Key Vault.
export TENANT_ID=$(echo "$(az account show -s $subscriptionName -o tsv --query 'tenantId')" | sed "s/\r//")

# Get current user context object ID. Need this to set initial Key Vault Access Policy so secrets etc. can be set/read in these scripts.
export USER_OBJECT_ID=$(echo "$(az ad signed-in-user show -o tsv --query 'objectId')" | sed "s/\r//")

# Deployment
export LOCATION="eastus2"

# Resource Groups
export RG_NAME_SECURITY="$resourceNamingInfix""-security-""$LOCATION"
export RG_NAME_SIG="$resourceNamingInfix""-sig-""$LOCATION"
export RG_NAME_NET="$resourceNamingInfix""-net-""$LOCATION"

# User-Assigned Managed Identity
export USERNAME_UAMI="$resourceNamingInfix""-vm-uami-""$LOCATION"

# Key Vault
export KEYVAULT_SKU_NAME="Standard"
export KEYVAULT_NAME="kv-""$resourceNamingInfix""-""$LOCATION"

# Network
export NSG_NAME="vm-test-nsg-""$LOCATION"
export VNET_NAME="vm-test-vnet-""$LOCATION"
export VNET_PREFIX="10.4.0.0/16"
export SUBNET_NAME="subnet1"
export SUBNET_PREFIX="10.4.1.0/24"

#SIG
export SIG_NAME="sig"

# Now assemble all the individual template paths
# ARM Templates
export TEMPLATE_UAMI="$templateRoot""identity.user-assigned-mi.json"
export TEMPLATE_KEYVAULT="$templateRoot""key-vault.json"
export TEMPLATE_KEYVAULT_SECRET="$templateRoot""key-vault.secret.json"
export TEMPLATE_NSG="$templateRoot""net.nsg.json"
export TEMPLATE_VNET="$templateRoot""net.vnet.json"
export TEMPLATE_SUBNET="$templateRoot""net.vnet.subnet.json"

# ##################################################
