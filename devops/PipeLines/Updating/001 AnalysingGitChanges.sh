#!/bin/bash
set -e
IFS=$'\n\n'

function AddHeadConfig()
{
	# sync config for later retries, not affected by cross-job.
    echo "<Project>
  <PropertyGroup>
    <AllPublishable>${1}</AllPublishable>
    <NoPublishable>${2}</NoPublishable>" > /tmp/cicd.props
}

function AddConfig()
{
	# sync config for later retries, not affected by cross-job.
	declare name=${1}
	declare publishable=${2}

	if [ "${publishable}" == "1" ]; then
	    echo "<${name}Publishable>${publishable}</${name}Publishable>" >> /tmp/cicd.props
	fi 
}

function AddTailConfig()
{
    echo "</PropertyGroup>
	</Project>" >> /tmp/cicd.props
}

if [ "${AllPublishable}" == "1" ]; 
then
    AddHeadConfig "1","0"
	AddTailConfig

	echo "All micro-services will be released."
else
	echo "Start analyzing the git difference log..."
	echo ""
	echo "the difference: "
	git diff --name-only ORIG_HEAD
	echo ""

	declare changes=$(git diff --name-only ORIG_HEAD)

	# Publishable by prefix
	function IsPublishable()
	{
		if
		echo $changes | grep "$1" > /dev/null
		then 
			eval "$2='1'" 
		else
			eval "$2='0'" 
			let count=$3+1
			eval $3="${count}"
		fi
	}
	
	declare services=$(ls -l src/services | awk 'NR>1')
	declare servicePrefix=""
	declare isPublishable
	declare publishableCount=0;

	AddHeadConfig "1","0"
	for service in ${services}
	do
	  servicePrefix=($(echo ${service} | awk '{print $9}')) 
	  # Notes: manual control, mandatory release, will not analyzing changes
	  isPublishable=$(eval echo ${servicePrefix}Publishable)
	  if [ "${isPublishable}" == "1" ]; 
      then
		  AddConfig "${servicePrefix}" "${isPublishable}"
		  echo "Tips[Hard Release]: ${servicePrefix} will be released."
      else
	      # Analyzing git changes
	      IsPublishable "src/${servicePrefix}" isPublishable publishableCount
		  AddConfig "${servicePrefix}" "${isPublishable}"
		  echo "Tips[Soft Release]: ${servicePrefix} will be released."
	  fi
	done
	AddTailConfig

	declare serviceCount=$(ls -l src/services | grep "^d" | wc -l)
	if [ "${publishableCount}" == "${serviceCount}" ] ;
	then
		AddHeadConfig "0","1"
		AddTailConfig
		echo "Tips: No services need to be released."
	fi
	
	echo ""
    echo "End analyzing the difference log..."
fi