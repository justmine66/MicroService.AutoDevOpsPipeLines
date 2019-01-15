#!/bin/bash
set -e
IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.config.sh
source ./devops/PipeLines/Functions.config.sh

# global variable
ReleaseEnvironmentOf Environment

GetAppName appName
echo ""
echo "[${Environment}]Begin creating ${appName}'s settings to the configmap of k8s..."

GetNameSpace namespace
kubectl create namespace ${namespace}

GetAccessToken accessToken
GetK8sApiServer k8sApiServer

for servicePrefix in `ls ./src/Services|xargs -d '/'`
do
  GetServiceName ${servicePrefix} serviceName
  GetServiceDir ${servicePrefix} ${serviceName} serviceDir
  CreateConfig ${Environment} ${namespace} ${k8sApiServer} ${serviceDir} ${servicePrefix} ${accessToken}
done

echo ""
echo "[${Environment}]End creating app settings to the configmap of k8s..."