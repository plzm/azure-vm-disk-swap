#!/bin/bash

# Delete existing deployment user key files, if any

delCmd="rm ./""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

delCmd="rm ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd
