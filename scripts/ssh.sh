#!/bin/bash

sshKeyName="ssh-test-1"
sshKeyType="ecdsa"
sshKeyBits=521
sshKeyPassphrase=""
sshPublicKeyUsername="pelazem"

ssh-keygen -q -f "./""$sshKeyName" -t "$sshKeyType" -b $sshKeyBits -N "$sshKeyPassphrase" -C "$sshPublicKeyUsername"
