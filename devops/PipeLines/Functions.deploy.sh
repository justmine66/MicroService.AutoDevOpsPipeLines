#!/bin/bash

set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh 

function CI()
{
    declare serviceName=$1
    declare publishFile=$2
    declare publishOutputDir="/tmp/${serviceName}"

    GetVersion version
    GetImageUserName registryUserName

    # repository name must be lowercase
    ToLower "${RegistryHost}/${registryUserName}/${serviceName}:${version}" imagefullname
	
    echo ""
    echo "Begin delivering for ${serviceName}..."
    echo "Tips: Image full name: ${imagefullname}"
    mkdir -p ${publishOutputDir}
    dotnet publish ${publishFile} -o ${publishOutputDir} -c release --no-restore  
    docker build -t ${imagefullname} ${publishOutputDir}
    docker push ${imagefullname}
    rm -fr ${publishOutputDir}
    echo "Delivery for ${serviceName} has been successful."
}

function CD()
{
    declare registryHost=$1
    declare registryUserName=$2
    declare serviceName=$3
    declare version=$4
    declare namespace=$5
    Replace ${serviceName} '.' '-' appName

    # repository name must be lowercase
    ToLower "${registryHost}/${registryUserName}/${serviceName}:${version}" imagefullname
    ToLower ${appName} appNameOfK8s

    # echo "Tips: namespace: ${namespace}, appNameOfK8s: ${appNameOfK8s}, imagefullname: ${imagefullname}"
    kubectl -n ${namespace} set image deployments/${appNameOfK8s} "${appNameOfK8s}=${imagefullname}"
    # [compatible]Staging environment does not need to change version number.
    if [ "${Environment}" == "Staging" ]; then
	    kubectl -n ${namespace} scale deploy ${appNameOfK8s} --replicas=0; 
	    kubectl -n ${namespace} scale deploy ${appNameOfK8s} --replicas=1; 
    fi
    echo "Deployment[${Environment}] for ${appName}:${version} has been successful."
}

function AutoScaling()
{
    declare namespace=$1
    declare serviceName=$2
    declare replicas=$3
    Replace ${serviceName} '.' '-' appName

    # repository name must be lowercase
    ToLower ${appName} appNameOfK8s

    kubectl -n ${namespace} scale deploy ${appNameOfK8s} --replicas=${replicas}; 
}
