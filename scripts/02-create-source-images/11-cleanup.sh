#!/bin/bash
set -eux

az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SOURCE" --yes --verbose
