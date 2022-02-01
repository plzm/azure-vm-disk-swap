#!/bin/bash

# https://docs.microsoft.com/cli/azure/sig/image-definition?view=azure-cli-latest#az_sig_image_definition_create

echo "Create Image Definition for upgrade VM - 2"
az sig image-definition create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEFINITION_IMG_SRC_1" --os-type "$VM_OS_TYPE" \
	--publisher "$OS_PUBLISHER_IMG_SRC_1" --offer "$OS_OFFER_IMG_SRC_1" --sku "$OS_SKU_IMG_SRC_1" \
	--hyper-v-generation "$HYPER_V_GENERATION" --os-state "$OS_STATE"

echo "Create Image Definition for upgrade VM - 3"
az sig image-definition create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMG_DEFINITION_IMG_SRC_2" --os-type "$VM_OS_TYPE" \
	--publisher "$OS_PUBLISHER_IMG_SRC_2" --offer "$OS_OFFER_IMG_SRC_2" --sku "$OS_SKU_IMG_SRC_2" \
	--hyper-v-generation "$HYPER_V_GENERATION" --os-state "$OS_STATE"
