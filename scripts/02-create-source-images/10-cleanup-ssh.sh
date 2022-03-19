#!/bin/bash
set -eux

# Clean out deploy identity
eval $(ssh-agent)
sshAddCmd="ssh-add -d ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME"
eval $sshAddCmd

# Delete existing SSH key files, if any
delCmd="rm ./""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

delCmd="rm ~/.ssh/""$DEPLOYMENT_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

delCmd="rm ./""$VM_ADMIN_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd

delCmd="rm ~/.ssh/""$VM_ADMIN_SSH_USER_KEY_NAME""*"
#echo $delCmd
eval $delCmd
