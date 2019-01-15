#!/bin/bash
set -e
IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.deploy.sh
source ./devops/PipeLines/Functions.deploy.sh

GetNameSpace namespace
GetReplicas replicas

if [ "${AllPublishable}" == "1" ]; 
then
    echo "Tips: All micro-services will be scaled, replicas: [${replicas}]."
    for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do
	  GetServiceName ${servicePrefix} serviceName
	  AutoScaling ${namespace} ${serviceName} ${replicas}
	done
else
	for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do
	  DynamicVariableValueOf "${servicePrefix}" "Publishable" isPublishable
	  if [ "${isPublishable}" == "1" ]; 
      then
		  echo "Tips: ${servicePrefix} will be scaled, replicas: [${replicas}]."
		  GetServiceName ${servicePrefix} serviceName
		  AutoScaling ${namespace} ${serviceName} ${replicas}
	  fi
	done
fi