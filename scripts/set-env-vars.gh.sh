#!/bin/bash

subscriptionName="Sandbox"

EV1=$(echo "$(az group show --subscription $subscriptionName -n 'azq' -o tsv --query 'location')" | sed "s/\r//")
echo "EV1=$EV1" >> $GITHUB_ENV
