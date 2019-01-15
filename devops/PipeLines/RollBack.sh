#!/bin/bash
set -e
IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.deploy.sh
source ./devops/PipeLines/Functions.deploy.sh

# global variable
ReleaseEnvironmentOf Environment

GetRollBackVersion version
GetNameSpace namespace
GetRegistryHost registryHost
GetImageUserName registryUserName

if [ "${AllPublishable}" == "1" ]; 
then
    echo "Tips: All micro-services will be roll-backed, version: ${version}."
    for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do
	  GetServiceName ${servicePrefix} serviceName
	  CD ${registryHost} ${registryUserName} ${serviceName} ${version} ${namespace}
	done
else
	for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do
	  DynamicVariableValueOf "${servicePrefix}" "Publishable" isPublishable
	  if [ "${isPublishable}" == "1" ]; 
      then
		  echo "Tips: ${servicePrefix} will be roll-backed, version: ${version}."
		  GetServiceName ${servicePrefix} serviceName
		  CD ${registryHost} ${registryUserName} ${serviceName} ${version} ${namespace}
	  fi
	done
fi