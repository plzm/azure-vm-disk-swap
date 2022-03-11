#!/bin/bash

getEnvVar() {
	# Retrieve an env var's value at runtime with dynamic variable name
  # Usage:
  # getEnvVar "variableName"

  varName=$1

	envVarName=$(echo -e "\x24""$varName")
	output=$(echo "echo ""$envVarName")
	eval $output
}

# Retrieve and echo
myVar=$(getEnvVar "MY_VAR")
echo $myVar
