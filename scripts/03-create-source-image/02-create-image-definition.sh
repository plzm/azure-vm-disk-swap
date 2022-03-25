#!/bin/bash

# https://docs.microsoft.com/cli/azure/sig/image-definition?view=azure-cli-latest#az_sig_image_definition_create

echo "Create Image Definition for vNext"
az sig image-definition create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -l "$LOCATION" --verbose \
	-r "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_VNEXT" --os-type "$VM_OS_TYPE" \
	--publisher "$OS_PUBLISHER_VNEXT" --offer "$OS_OFFER_VNEXT" --sku "$OS_SKU_VNEXT" \
	--hyper-v-generation "$HYPER_V_GENERATION" --os-state "$OS_STATE"
