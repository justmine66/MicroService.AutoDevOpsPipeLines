#!/bin/bash
set -e
IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh

# global variable
ReleaseEnvironmentOf Environment

GetAppName appName

echo "[${Environment}]Starting release for ${appName}, it will dynamicly create k8s environment..."

GetVersion version
GetNameSpace namespace

echo ""
echo "Please check the image version of each microservice carefully !!!"
echo "kubernetes's namespace: ${namespace}"
for servicePrefix in `ls ./src/Services|xargs -d '/'`
do
  GetServiceName ${servicePrefix} serviceName
  echo "${serviceName}: ${version}"
done

echo ""

GetMajor major
GetReplicas replicas
GetRegistryHost RegistryHost
GetImageUserName registryUserName
ToLower ${Environment} environment
ToLower "${appName}.v${major}" releaseName

helm install /root/AutoDevOpsPipeLinesCharts \
--name=${releaseName} \
--set environment.upper=${Environment} \
--set environment.lower=${environment} \
--set namespace=${namespace} \
--set image.registryhost=${RegistryHost} \
--set image.username=${registryUserName} \
--set image.version=${version} \
--set replicas=${replicas}

echo ""
echo "[${Environment}]K8s environment Created Successfully !!!"