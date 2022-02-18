#!/bin/bash

az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SOURCE" --yes --verbose


#echo "Delete Image Definition for src VM - 1"
#az sig image-definition delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --verbose \
#	-r "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEFINITION_IMG_SRC_1"

#echo "Delete Image Definition for src VM - 2"
#az sig image-definition delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" --verbose \
#	-r "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEFINITION_IMG_SRC_2"
