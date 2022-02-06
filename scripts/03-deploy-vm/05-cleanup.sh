#!/bin/bash

# This script only cleans up what is not needed anymore to do OS disk switches on deployed workload VMs.
# To delete everything, use ../delete-all/02-delete-all-resources.sh instead.

# WARNING - this will delete ALL resource in all of these Resource Groups

az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_DEPLOY" --yes --verbose
