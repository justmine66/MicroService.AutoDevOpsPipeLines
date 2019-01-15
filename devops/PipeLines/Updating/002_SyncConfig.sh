#!/bin/bash
set -e
IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.config.sh
source ./devops/PipeLines/Functions.config.sh

# global variable
RollEnvironmentOf Environment

GetAppName appName
echo ""
echo "Begin synchronizing ${appName}'s settings to the configmap of k8s..."

GetCiCdSettings allPublishable noPublishable
if [ "${noPublishable}" == "1" ] ;
then
    echo ""
    echo "Tips: No services need to be synced config."
else
	GetNameSpace namespace
    GetAccessToken accessToken
    GetK8sApiServer k8sApiServer

	for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do

	  IsPublishableOf ${servicePrefix} isPublishable
	  GetServiceName ${servicePrefix} serviceName

	  if [ "${isPublishable}" == "1" ]; 
	  then
	      echo ""
	      echo "Tips: ${serviceName} begin synchronizing config!!!"
          GetServiceDir ${servicePrefix} ${serviceName} serviceDir
          CreateConfig ${Environment} ${namespace} ${k8sApiServer} ${serviceDir} ${servicePrefix} ${accessToken}
	  else
	      echo ""
	      echo "Tips: ${serviceName} will not be synced config!!!"
	  fi 
	done
fi

echo ""
echo "End synchronizing app settings to the configmap of k8s..."