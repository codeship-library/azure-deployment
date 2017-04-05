#!/bin/sh

# Login into azure using SPN
	if [ az account show &>/dev/null ]; then
		echo "You are already logged in to Azure..."
	else
		echo "Logging into Azure..."
			az login \
				--service-principal \
				-u $spn \
				-p $password \
				--tenant $tenant &>/dev/null
			echo "Successfully logged into Azure..."
	fi

	# Code to capture ACS master info
        master_fqdn=$(az acs show -n $Servicename -g $Resource | jq -r '.masterProfile | .fqdn')
        echo "Successfully captured your Master FQDN: $master_fqdn" 

# Check if K8 and setup Kubectl
	echo "Installing Kubectl..."
	az acs kubernetes install-cli
	az acs kubernetes get-credentials --resource-group=$Resource --name=$Servicename
	echo "Successfully installed Kubectl..." 

# kubectl check if first arg is `-f` or `--some-option`
	if [ "${1:0:1}" = '-' ]; then
		set -- "$@"
	fi

# If our command is a valid kubectl subcommand, invoke it through kubectl instead
	if kubectl help "$1" &>/dev/null; then
		set -- "$@"
	fi
# Out to end user and execute kubectl command
	echo "Reminder: Your web applications can be viewed here: $master_fqdn"
	sleep 5
	echo "Executing supplied $Orchestrator command: '$@'"
	# Retry logic for executing command
	n=0
	until [ $n -ge 5 ]
	do
		eval "$@" && echo "'$@' completed"  && break
		n=$((n+1)) &>/dev/null && echo "Retrying '$@'in 5 seconds..."
		sleep 5
	done
	exit $? 
