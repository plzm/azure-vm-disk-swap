#!/bin/bash

getEnvVar() {
  #Usage:
  #getEnvVar "variableName"

  varName=$1

	if [ ! -z $CI ]
	then
		# We are in GitHub CI environment

		envVarName=$(echo -e "\x24{{ env.""$varName"" }}")
	else
		# We are in a non-GitHub environment

		envVarName=$(echo -e "\x24""$varName")
	fi

	retVal=$(echo "echo ""$envVarName")
	eval $retVal
}

export foo="bar"

result=$(getEnvVar "foo")

echo $result
