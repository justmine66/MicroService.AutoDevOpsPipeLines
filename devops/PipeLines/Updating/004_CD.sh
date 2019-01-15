#!/bin/bash
set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.deploy.sh
source ./devops/PipeLines/Functions.deploy.sh

# global variable
RollEnvironmentOf Environment

GetAppName appName

echo "Continuous deployment[${Environment}] for ${appName} starting..." 

GetCiCdSettings allPublishable noPublishable

if [ "${noPublishable}" == "1" ] ;
then
    echo ""
    echo "Tips: No services need to be cded."
else
	GetVersion version
	GetNameSpace namespace
	GetRegistryHost registryHost
	GetImageUserName registryUserName

	for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do
	  IsPublishableOf ${servicePrefix} isPublishable
	  GetServiceName ${servicePrefix} serviceName
	  if [ "${isPublishable}" == "1" ]; 
	  then
		  echo ""
	      echo "Tips: ${serviceName} begin deployment to K8S!!!"
		  CD ${registryHost} ${registryUserName} ${serviceName} ${version} ${namespace}
	  else
	      echo ""
	      echo "Tips: ${serviceName} will not be deploymented to K8S!!!"
	  fi 
	done
fi

echo ""
echo "Continuous deployment[${Environment}] for ${appName} has been successful."
