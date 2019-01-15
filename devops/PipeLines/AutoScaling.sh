#!/bin/bash
set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.deploy.sh
source ./devops/PipeLines/Functions.deploy.sh

# global variable
RollEnvironmentOf Environment

GetAppName appName

echo "[${Environment}]Auto scaling for ${appName} starting..." 

GetCiCdSettings allPublishable noPublishable

if [ "${noPublishable}" == "1" ] ;
then
    echo ""
    echo "Tips: No services need to be cded."
else
	GetNameSpace namespace
	GetReplicas replicas

	for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do
	  IsPublishableOf ${servicePrefix} isPublishable
	  GetServiceName ${servicePrefix} serviceName
	  if [ "${isPublishable}" == "1" ]; 
	  then
		  echo ""
	      echo "Tips: ${serviceName} begin scaling, replicas: [${replicas}]!!!"
		  AutoScaling ${namespace} ${serviceName} ${replicas}
	  else
	      echo ""
	      echo "Tips: ${serviceName} will not be scaled!!!"
	  fi 
	done
fi

echo ""
echo "[${Environment}]Auto scaling for ${appName} has been successful."