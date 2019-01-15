#!/bin/bash
set -e
IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh

# global variable
ReleaseEnvironmentOf Environment

GetAppName appName

echo "[${Environment}]Start dynamically building the gateway route for ${appName}..."

# resilience handle
# Maximum time in seconds that you allow the whole operation to take.
declare maxTime=5 
# Maximum time in seconds that you allow the connection to the server to take.
declare maxConnectTime=2
declare retryCount=5

## add services
function createService()
{
	curl -X POST $1 \
	--connect-timeout $2 \
	--max-time $3 \
	--retry $4 \
	-H  "accept: application/json" \
	-H  "Content-Type: application/json" \
	-d "{ \"name\": \"$5\",  \"url\": \"$6\"}";
}

## add routes
function createRoute()
{
    declare svcResponse=$(curl -X GET ${kongServiceBaseUrl}/$5 --connect-timeout $2 --max-time $3 --retry $4)
    declare JQ_EXEC=`which jq`
    declare svcId=$(echo $svcResponse | ${JQ_EXEC} .id | sed 's/\"//g')
	declare defMethods="[\"GET\",\"POST\"]"

	set +e
	if [ -n "$8" ]; then
	   defMethods=$8
	fi

	if [ -z "$svcId" ]; then
	  echo "Warnning, failed to get the service[$5] identifier, route cannot be created.";
    else
	  # idempotent
	  declare routesAdded=$(curl -X GET ${kongServiceBaseUrl}/$5/routes)
	  declare routeid=$(echo $routesAdded | ${JQ_EXEC} .data[0].id | sed 's/\"//g')
	  if [ "$routeid" == "null" ]; then
        curl -X POST $1 \
	    --connect-timeout $2 \
	    --max-time $3 \
	    --retry $4 \
	    -H  "accept: application/json" \
	    -H  "Content-Type: application/json" \
	    -d "{ \"service\": "{\"id\":\"$svcId\"}",\"paths\": "[\"$6\"]",\"methods\": "$defMethods",\"strip_path\":$7,\"hosts\": "[\"${KongRouteDomain}\"]"}";
      fi
	fi
	set -e
}

GetMajor major
GetNameSpace namespace
GetKongApiServer KongApiServer
GetKongRouteDomain KongRouteDomain

declare fdnOfK8s="${namespace}.svc.cluster.local"
declare kongServiceBaseUrl="${KongApiServer}/services"
declare kongRouteBaseUrl="${KongApiServer}/routes"
declare releaseVersion="v${major}"

for servicePrefix in `ls ./src/Services|xargs -d '/'`
do
  GetServiceName ${servicePrefix} serviceName
  # replace . to -, compatible with k8s.
  Replace ${serviceName} '.' '-' serviceName
  ToLower "${serviceName}-${releaseVersion}" serviceNameWithVersion
  ToLower "${serviceName}.${fdnOfK8s}" serviceFdn
  ToLower ${servicePrefix} prefix
  ToLower "http://${serviceFdn}/api/${prefix}" serviceUrl

  echo "Begin creating service[${serviceNameWithVersion}]"
  createService ${kongServiceBaseUrl} ${maxConnectTime} ${maxTime} ${retryCount} ${serviceNameWithVersion} ${serviceUrl}

  echo "Begin creating route of service[${serviceNameWithVersion}]" 
  ToLower "/api/${releaseVersion}/${prefix}" serviceRouteUrl
  createRoute ${kongRouteBaseUrl} ${maxConnectTime} ${maxTime} ${retryCount} ${serviceNameWithVersion} ${serviceRouteUrl} true
done

echo ""
echo "[${Environment}]Dynamicly building gateway route successfully !!!"