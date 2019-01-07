#!/bin/bash
set -e
IFS=$'\n\n'

declare appName=($(grep -oP '(?<=AppName>)[^<]+' "devops/app.props"))

echo "Start building the gateway for ${appName} route dynamically..."

declare namespace=($(grep -oP '(?<=Namespace>)[^<]+' "devops/app.props"))
declare namespaceOfK8s=$(echo "${appName}-v${major}" | tr 'A-Z' 'a-z')
declare fdnOfK8s="${namespaceOfK8s}.svc.cluster.local"
declare kongServiceUrl=($(grep -oP '(?<=Namespace>)[^<]+' "devops/app.props"))
declare major=($(grep -oP '(?<=Major>)[^<]+' "devops/version.props"))
declare releaseVersion="v${major}"

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
	    -d "{ \"service\": "{\"id\":\"$svcId\"}",\"paths\": "[\"$6\"]",\"methods\": "$defMethods",\"strip_path\":$7,\"hosts\": "[\"$kongRouteDomain\"]"}";
      fi
	fi
	set -e
}

declare services=$(ls -l src/services | awk 'NR>1')
declare servicePrefix=""
declare serviceName=""
declare serviceNameWithVersion=""
declare serviceFullName=""
declare serviceUrl=""
declare serviceRouteUrl=""
for service in ${services}
do
  servicePrefix=($(echo ${service} | awk '{print $9}')) 
  serviceName="${servicePrefix}-api"
  serviceNameWithVersion="${serviceName}-${releaseVersion}"
  serviceFullName="${serviceName}.${fdnOfK8s}"
  serviceUrl="http://${serviceFullName}/api/${servicePrefix}"

  echo "Begin creating service[${serviceNameWithVersion}]"
  createService ${kongServiceUrl} ${maxConnectTime} ${maxTime} ${retryCount} ${serviceNameWithVersion} ${serviceUrl}

  echo "Begin creating route of service[${serviceNameWithVersion}]" 
  serviceRouteUrl="/api/${releaseVersion}/${servicePrefix}"
  createRoute ${kongServiceUrl} ${maxConnectTime} ${maxTime} ${retryCount} ${serviceNameWithVersion} ${serviceRouteUrl} true
done

echo ""
echo "Dynamicly building gateway route successfully !!!"