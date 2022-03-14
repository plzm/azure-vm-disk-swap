#!/bin/bash

# https://docs.microsoft.com/cli/azure/sig/image-definition?view=azure-cli-latest#az_sig_image_definition_create

echo "Create Image Definition for v2"
az sig image-definition create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -l "$LOCATION" --verbose \
	-r "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_V2" --os-type "$VM_OS_TYPE" \
	--publisher "$OS_PUBLISHER_2" --offer "$OS_OFFER_2" --sku "$OS_SKU_2" \
	--hyper-v-generation "$HYPER_V_GENERATION" --os-state "$OS_STATE"

echo "Create Image Definition for v3"
az sig image-definition create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -l "$LOCATION" --verbose \
	-r "$GALLERY_NAME" --gallery-image-definition "$VM_IMG_DEF_NAME_V3" --os-type "$VM_OS_TYPE" \
	--publisher "$OS_PUBLISHER_3" --offer "$OS_OFFER_3" --sku "$OS_SKU_3" \
	--hyper-v-generation "$HYPER_V_GENERATION" --os-state "$OS_STATE"
