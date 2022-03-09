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

setEnvVar() {
	# Set an env var's value at runtime with dynamic variable name
	# If in GitHub Actions runner, will export env var both to Actions 
  # Usage:
  # setEnvVar "variableName" "variableValue"

  varName=$1
  varValue=$2

	if [ ! -z $GITHUB_ACTIONS ]
	then
		# We are in GitHub CI environment - export to GitHub Actions workflow for later interpolation where GHA does interpolation off-runner
		cmd=$(echo -e "echo \x22""$varName""=""$varValue""\x22 \x3E\x3E \x24GITHUB_ENV")
		eval $cmd
	fi

	# Export for local/immediate use, whether on GHA runner or shell/wherever
	cmd="export ""$varName""=\"""$varValue""\""
	eval $cmd
}

varName="FOO"

setEnvVar "$varName" "bar"

getEnvVar "$varName"
