#!/bin/bash

az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_VM_SOURCE" --yes --verbose
