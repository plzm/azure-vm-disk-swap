#!/bin/bash

getEnvVar() {
  #Usage:
  #getEnvVar "variableName"

  varName=$1

	#if [ ! -z $GITHUB_ACTIONS ]
	#then
	#	# We are in GitHub CI environment

		#envVarName=$(echo -e "\x24{{ env.""$varName"" }}")
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
		# We are in GitHub CI environment - export to GitHub Actions workflow for later interpolation in addition to below export for local/immediate use
		cmd=$(echo -e "echo \x22""$varName""=""$varValue""\x22 \x3E\x3E \x24GITHUB_ENV")
		eval $cmd
	#else
		# We are in a non-GitHub environment
		#cmd="export ""$varName""=\"""$varValue""\""
	fi

	cmd="export ""$varName""=\"""$varValue""\""
	eval $cmd
}

varName="FOO"

setEnvVar "$varName" "bar"

getEnvVar "$varName"

echo "Hello"