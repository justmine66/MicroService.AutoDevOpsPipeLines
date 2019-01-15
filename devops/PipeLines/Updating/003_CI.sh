#!/bin/bash

set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.deploy.sh
source ./devops/PipeLines/Functions.deploy.sh

# global variable
RollEnvironmentOf Environment

GetAppName appName
echo "Continuous integration[${Environment}] for ${appName} starting..."

GetCiCdSettings allPublishable noPublishable
if [ "${noPublishable}" == "1" ] ;
then
    echo ""
    echo "Tips: No services need to be cied."
else
    echo ""
    echo "${appName} building..."
    GetSolutionName solutionName
    dotnet build ${solutionName}	 

	GetRegistryHost RegistryHost
	for servicePrefix in `ls ./src/Services|xargs -d '/'`
	do
	    IsPublishableOf ${servicePrefix} isPublishable
		GetServiceName ${servicePrefix} serviceName
		if [ "${isPublishable}" == "1" ]; 
	    then
		    echo ""
	        echo "Tips: ${serviceName} begin integrating to image registry!!!"
		    GetServiceCsProjFile ${servicePrefix} ${serviceName} serviceCsProjFile
		    CI ${serviceName} ${serviceCsProjFile}
	    else
	        echo ""
	        echo "Tips: ${serviceName} will not be integrated to image registry!!!"
	    fi 
	done
fi

echo ""
echo "Continuous integration[${Environment}] for ${appName} has been successful."