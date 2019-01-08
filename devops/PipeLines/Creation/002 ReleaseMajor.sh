#!/bin/bash
set -e
IFS=$'\n\n'

declare appName=($(grep -oP '(?<=AppName>)[^<]+' "devops/app.props"))

echo "Release for ${appName} starting, dynamicly creating k8s environment..."

declare major=($(grep -oP '(?<=Major>)[^<]+' "devops/version.props"))
declare minor=($(grep -oP '(?<=Minor>)[^<]+' "devops/version.props"))
declare patch=($(grep -oP '(?<=Patch>)[^<]+' "devops/version.props"))
declare namespace=($(grep -oP '(?<=Namespace>)[^<]+' "devops/app.props"))

declare version=${major}.${minor}.${patch}
declare namespaceOfK8s=$(echo "${namespace}-v${major}" | tr 'A-Z' 'a-z')
declare releaseName="${appName}-v${major}"

echo ""
echo "Please check the image version of each microservice carefully !!!"
echo "kubernetes's namespace: ${namespaceOfK8s}"
declare services=$(ls -l src/services | awk 'NR>1')
declare servicePrefix=""
for service in ${services}
do
  servicePrefix=($(echo ${service} | awk '{print $9}')) 
  echo "${servicePrefix}: ${version}"
done

echo ""
declare replicas=($(grep -oP '(?<=Replicas>)[^<]+' "devops/app.props"))

helm install /root/AutoDevOpsPipeLinesCharts \
--name=${releaseName} \
--set environment.upper=${Environment} \
--set environment.lower=$(echo ${Environment} | tr 'A-Z' 'a-z') \
--set namespace=${namespaceOfK8s}  \
--set image.version=${version} \
--set replicas=${replicas}

echo ""
echo "Dynamicly creating k8s environment Successfully !!!"