#!/bin/bash
set -e
IFS=$'\n\n'

declare appName=($(grep -oP '(?<=AppName>)[^<]+' "devops/app.props"))

echo "Begin creating ${appName}'s settings to the configmap of k8s..."

function Create()
{
	declare createUrl="$3/api/v1/namespaces/$2/configmaps?pretty=true"
	echo "[environment: $1, namespace: $2]"

	function send()
	{
		set +e

		declare deleteUrl="${BaseUrl}/api/v1/namespaces/${namespace}/configmaps/$5"

		curl -X DELETE $deleteUrl -k \
		--connect-timeout $2 --max-time $3 --retry $4 \
		-H 'Authorization: Bearer '${AccessToken}'' 

		set -e

		declare configInfo=$(cat $1 | jq tostring)

		curl -X POST $createUrl -k \
		--connect-timeout $2 --max-time $3 --retry $4 \
		-H 'Content-Type: application/json' \
		-H 'cache-control: no-cache' \
		-H 'Authorization: Bearer '${AccessToken}'' \
		-d '{
	"kind": "ConfigMap",
	"apiVersion": "v1",
	"metadata": {
	"name": "'$5'",
	"namespace": "'${namespace}'"
	},
	"data": {
	"'$6'":'"$configInfo"'
	}
}'
	}

	declare maxTime=30 
	declare maxConnectTime=20
	declare retryCount=5
	
	send "$4/appsettings.json" $maxConnectTime $maxTime $retryCount "$5.appsettings.json" "appsettings.json"
	send "$4/appsettings.$1.json" $maxConnectTime $maxTime $retryCount "$(echo $5.appsettings.$1.json | tr 'A-Z' 'a-z')" "appsettings.$1.json"
}

declare major=($(grep -oP '(?<=VersionMajor>)[^<]+' "devops/version.props"))
declare namespace=($(grep -oP '(?<=Namespace>)[^<]+' "devops/app.props"))
declare namespaceOfK8s=$(echo "${namespace}-v${major}" | tr 'A-Z' 'a-z')
declare k8sApiServer=($(grep -oP '(?<=K8sApiServer>)[^<]+' "devops/deploy.props"))

kubectl create namespace ${namespaceOfK8s}

declare services=$(ls -l src/services | awk 'NR>1')
declare servicePrefix=""
for service in ${services}
do
  servicePrefix=($(echo ${service} | awk '{print $9}')) 
  Create ${Environment} ${namespaceOfK8s} ${k8sApiServer} "./src/${servicePrefix}.API" "${servicePrefix}" 
done

echo ""
echo "End creating app settings to the configmap of k8s..."