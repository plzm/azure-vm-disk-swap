#!/bin/bash

getEnvVar() {
  #Usage:
  #getEnvVar "variableName"

  varName=$1

	#if [ ! -z $GITHUB_ACTIONS ]
	#then
	#	# We are in GitHub CI environment

	#	envVarName=$(echo -e "\x24{{ env.""$varName"" }}")
	#else
		# We are in a non-GitHub environment

		envVarName=$(echo -e "\x24""$varName")
	#fi

	retVal=$(echo "echo ""$envVarName")
	eval $retVal
}

setEnvVar() {
  #Usage:
  #setEnvVar "variableName" "variableValue"

  varName=$1
  varValue=$2

	if [ ! -z $GITHUB_ACTIONS ]
	then
		# We are in GitHub CI environment
		cmd=$(echo -e "echo \x22""$varName""=""$varValue""\x22 \x3E\x3E \x24GITHUB_ENV")
	else
		# We are in a non-GitHub environment
		cmd="export ""$varName""=\"""$varValue""\""
	fi

	eval $cmd
}

setEnvVar "FOO" "bar"

getEnvVar "FOO"
