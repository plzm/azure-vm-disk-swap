#!/bin/bash

./01-set-key-vault-access-policy.sh
./02-write-admin-ssh-to-kv.sh
./03-create-deploy-ssh.sh
./04-write-deploy-ssh-to-kv.sh
./05-cleanup-deploy-ssh.sh
