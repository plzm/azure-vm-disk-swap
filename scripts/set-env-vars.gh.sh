#!/bin/bash

subscriptionName="Sandbox"

EV17=$(echo "$(az group show --subscription $subscriptionName -n 'azq' -o tsv --query 'location')" | sed "s/\r//")
echo "EV17=$EV17" >> $GITHUB_ENV
