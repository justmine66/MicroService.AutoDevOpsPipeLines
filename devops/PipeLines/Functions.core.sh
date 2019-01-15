#!/bin/bash

set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.common.sh
source ./devops/PipeLines/Functions.common.sh

# function GetServices()
# {
#	
# }

function GetServiceCsProjFile()
{
    declare prefix=${1}
	declare name=${2}
	declare csprojFile="./src/Services/${prefix}/${name}/${name}.csproj"
	eval $3="${csprojFile}"
}

function GetServiceDir()
{
    declare prefix=${1}
	declare name=${2}
	declare dir="./src/Services/${prefix}/${name}"
	eval $3="${dir}"
}

function GetServiceName()
{
    declare prefix=${1}
	declare name=($(ls ./src/Services/${prefix}|head -n 1|xargs -d '/' echo))
	eval $2="${name}"
}

function GetAppName()
{
    declare name=($(grep -oP '(?<=AppName>)[^<]+' "./devops/app.props"))
	eval $1="${name}"
}

function GetNameSpace()
{
    GetMajor major
	declare ns=($(grep -oP '(?<=NameSpace>)[^<]+' "./devops/app.props"))
	ToLower "${ns}-v${major}" nsOfK8s
	eval $1=${nsOfK8s}
}

function GetSolutionName()
{
    declare name=($(grep -oP '(?<=SolutionName>)[^<]+' "./devops/app.props"))
	eval $1="${name}"
}

function GetImageUserName()
{
    declare name=($(grep -oP '(?<=ImageUserName>)[^<]+' "devops/deploy.props"))
	eval $1="${name}"
}

function GetCiCdSettings()
{
    declare all=($(grep -oP '(?<=AllPublishable>)[^<]+' "/tmp/cicd.props"))
    declare no=($(grep -oP '(?<=NoPublishable>)[^<]+' "/tmp/cicd.props"))
	eval $1=${all}
	eval $2=${no}
}

function GetMajor()
{
    declare m=($(grep -oP '(?<=Major>)[^<]+' "./devops/version.props"))
	eval $1=${m}
}

function GetVersion()
{
    declare major=($(grep -oP '(?<=Major>)[^<]+' "./devops/version.props"))
	declare minor=($(grep -oP '(?<=Minor>)[^<]+' "./devops/version.props"))
	declare patch=($(grep -oP '(?<=Patch>)[^<]+' "./devops/version.props"))
	eval $1="${major}.${minor}.${patch}"
}

function GetNumericVersion()
{
	declare major=($(grep -oP '(?<=Major>)[^<]+' "./devops/version.props"))
	declare minor=($(grep -oP '(?<=Minor>)[^<]+' "./devops/version.props"))
	declare patch=($(grep -oP '(?<=Patch>)[^<]+' "./devops/version.props"))

	eval $1=${major}${minor}${patch}
}

function GetRollBackVersion()
{
	GetNumericVersion currentVersion
	declare step=($(grep -oP '(?<=RollBackStep>)[^<]+' "devops/deploy.props"))
	declare rollbackVersion=`expr $currentVersion - $step` 
	declare versionStr=""
	if [ "$rollbackVersion" -lt "100" ] 
	then
	   versionStr="0.${rollbackVersion:0:1}.${rollbackVersion:1:1}"
	else
	   versionStr="${rollbackVersion:0:1}.${rollbackVersion:1:1}.${rollbackVersion:2:1}"
	fi

	eval $1=${versionStr}
}

function GetImageRegistrySettings()
{
    declare host=($(grep -oP '(?<=ImageRegistryHost>)[^<]+' "devops/deploy.props"))
    declare username=($(grep -oP '(?<=ImageUserName>)[^<]+' "devops/deploy.props"))
	eval $1=${host}
	eval $2=${username}
}

function GetReplicas()
{
    declare count=($(grep -oP '(?<=Replicas>)[^<]+' "devops/deploy.props"))
	eval $1=${count}
}

function GetAccessToken()
{
    ToLower ${Environment} environment
    declare token=($(grep -oP "(?<=AccessToken>)[^<]+" "devops/deploy.${environment}.props"))
	eval $1="${token}"
}

function GetRegistryHost()
{
    ToLower ${Environment} environment
    declare host=($(grep -oP "(?<=RegistryHost>)[^<]+" "devops/deploy.${environment}.props"))
	eval $1="${host}"
}

function GetK8sApiServer()
{
    ToLower ${Environment} environment
    declare host=($(grep -oP "(?<=K8sApiServer>)[^<]+" "devops/deploy.${environment}.props"))
	eval $1="${host}"
}

function GetKongApiServer()
{
    ToLower ${Environment} environment
    declare host=($(grep -oP "(?<=KongApiServer>)[^<]+" "devops/deploy.${environment}.props"))
	eval $1="${host}"
}

function GetKongRouteDomain()
{
    ToLower ${Environment} environment
    declare domain=($(grep -oP "(?<=KongRouteDomain>)[^<]+" "devops/deploy.${environment}.props"))
	eval $1="${domain}"
}

function IsPublishableOf()
{
    declare prefix=$1
    declare isP=($(grep -oP "(?<=${prefix}Publishable>)[^<]+" "/tmp/cicd.props"))
	eval $2="${isP}"
}

# get updating's environment of branch
function RollEnvironmentOf()
{
	declare branch=${CI_COMMIT_REF_NAME}
	declare name=($(grep -oP "(?<=${branch}>)[^<]+" "./devops/branch.env.props"))
	FirstCharUpperCase ${name} env
	eval $1="${env}"
}

# get creation's environment of branch
function ReleaseEnvironmentOf()
{
    declare branch=${CI_COMMIT_REF_NAME}
	declare name=($(echo "${branch}"|xargs -d '/'|awk '{print $2}'))
	FirstCharUpperCase ${name} env
	eval $1="${env}"
}