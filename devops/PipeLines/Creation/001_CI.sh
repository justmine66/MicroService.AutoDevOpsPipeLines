#!/bin/bash

set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.deploy.sh
source ./devops/PipeLines/Functions.deploy.sh

# global variable
ReleaseEnvironmentOf Environment

GetAppName appName
echo ""
echo "[${Environment}]Continuous integration for ${appName} starting..."

echo ""
echo "${appName} building..."
GetSolutionName solutionName
dotnet build ${solutionName}	 

GetRegistryHost RegistryHost
for servicePrefix in `ls ./src/Services|xargs -d '/'`
do
    echo ""
    echo "Tips: ${servicePrefix} begin integrating to image registry!!!"
    GetServiceName ${servicePrefix} serviceName
    GetServiceCsProjFile ${servicePrefix} ${serviceName} serviceCsProjFile
    CI ${serviceName} ${serviceCsProjFile}
done

echo ""
echo "[${Environment}]Continuous integration for ${appName} has been successful."
