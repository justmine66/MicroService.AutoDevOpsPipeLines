#!/bin/bash

set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh

function CreateConfig()
{
    declare ns=$2
    declare apiServer=$3
    declare token=$6
	declare createUrl="${apiServer}/api/v1/namespaces/$2/configmaps?pretty=true"
	echo ""
	echo "[environment: $1, namespace: $2]"

	function Send()
	{
		set +e

		declare deleteUrl="${apiServer}/api/v1/namespaces/${ns}/configmaps/$5"

		curl -X DELETE $deleteUrl -k \
		--connect-timeout $2 --max-time $3 --retry $4 \
		-H 'Authorization: Bearer '${token}'' 

		set -e

		declare configInfo=$(cat $1 | jq tostring)

		curl -X POST $createUrl -k \
		--connect-timeout $2 --max-time $3 --retry $4 \
		-H 'Content-Type: application/json' \
		-H 'cache-control: no-cache' \
		-H 'Authorization: Bearer '${token}'' \
		-d '{
	"kind": "ConfigMap",
	"apiVersion": "v1",
	"metadata": {
	"name": "'$5'",
	"namespace": "'${ns}'"
	},
	"data": {
	"'$6'":'"${configInfo}"'
	}
}'
	}

	declare maxTime=30 
	declare maxConnectTime=20
	declare retryCount=5
	
	ToLower "$5.appsettings.json" configName
	ToLower "$5.appsettings.$1.json" configEnvName

	Send "$4/appsettings.json" $maxConnectTime $maxTime $retryCount ${configName} "appsettings.json"
	Send "$4/appsettings.$1.json" $maxConnectTime $maxTime $retryCount ${configEnvName} "appsettings.$1.json"
}