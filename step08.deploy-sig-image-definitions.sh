#!/bin/bash

# https://docs.microsoft.com/cli/azure/sig/image-definition?view=azure-cli-latest#az_sig_image_definition_create

echo "Create Image Definition 1"
az sig image-definition create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMAGE_DEFINITION_1" --os-type "$VM_OS_TYPE" \
	--publisher "$OS_PUBLISHER" --offer "$OS_OFFER" --sku "$OS_SKU_1" \
	--hyper-v-generation "$HYPER_V_GENERATION" --os-state "$OS_STATE"

echo "Create Image Definition 2"
az sig image-definition create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	-r "$SIG_NAME" --gallery-image-definition "$VM_IMAGE_DEFINITION_2" --os-type "$VM_OS_TYPE" \
	--publisher "$OS_PUBLISHER" --offer "$OS_OFFER" --sku "$OS_SKU_2" \
	--hyper-v-generation "$HYPER_V_GENERATION" --os-state "$OS_STATE"
