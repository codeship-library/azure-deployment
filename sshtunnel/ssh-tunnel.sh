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

    # Code to capture ACS agents info
        agents_fqdn=$(az acs show -n $Servicename -g $Resource | jq -r '.agentPoolProfiles[0].fqdn')
        echo "Successfully captured your Agents FQDN: $agents_fqdn"

# Create SSH Tunnel and check to ensure tunnel is successfully created, if errors, try again up to 5 times
	echo "Opening SSH tunnel to ACS..."
		n=0
		until [ $n -ge 5 ]
		do
			ssh -fNL $local_port:localhost:$remote_port -p 2200 azureuser@$master_fqdn -o StrictHostKeyChecking=no -o ServerAliveInterval=240 &>/dev/null && echo "ACS SSH Tunnel successfully opened..." && break
			n=$((n+1)) &>/dev/null && echo "SSH tunnel is not ready. Retrying in 5 seconds..."
			sleep 5
		done 

# Check for ACS Cluster Node availability, if errors, try again up to 5 times - only necessary if ACS Cluster was recently deployed
	n=0
	until [ $n -ge 5 ]
	do
		docker info | grep 'Nodes: [1-9]' &>/dev/null && echo "$Orchestrator cluster is ready..." && break
		n=$((n+1)) &>/dev/null && echo "$Orchestrator cluster is not ready. Retrying in 45 seconds..."
		sleep 45
	done 

# Docker check if first arg is `-f` or `--some-option`
	if [ "${1:0:1}" = '-' ]; then
		set -- docker "$@"
	fi

# If our command is a valid Docker subcommand, invoke it through Docker instead - (this allows for "docker run docker ps", etc)
	if docker help "$1" &>/dev/null; then
		set -- docker "$@"
	fi
# Out to end user and execute docker command
	echo "Reminder: Your web applications can be viewed here: $agents_fqdn"
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