#!/bin/bash

# Delete existing SSH key files, if any
delCmd="rm ./""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

delCmd="rm ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

delCmd="rm ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd
