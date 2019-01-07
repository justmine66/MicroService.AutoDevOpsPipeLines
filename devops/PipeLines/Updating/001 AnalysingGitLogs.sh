#!/bin/bash
set -e
IFS=$'\n\n'

function SyncConfig()
{
	# sync config for later retries, not affected by cross-job.
    echo "<Project>
  <PropertyGroup>
    <AllPublishable>${1}</AllPublishable>
    <EmptyPublishable>${2}</EmptyPublishable>
    <ApiPublishable>${3}</ApiPublishable>
    <WebPublishable>${4}</WebPublishable>
  </PropertyGroup>
</Project>
" > /tmp/cicd.props
}

if [ "${AllPublishable}" == "1" ]; 
then
	SyncConfig "1" "1" "1" 

	echo "All micro-services will be released."
else
	echo "Start analyzing the difference log..."
	echo ""
	echo "the difference: "
	git diff --name-only ORIG_HEAD
	echo ""

	declare changes=$(git diff --name-only ORIG_HEAD)

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

	declare PublishableCount=0;
	IsPublishable "src/Ziya.Api" ApiPublishable PublishableCount
	IsPublishable "src/Ziya.Web" WebPublishable PublishableCount

	declare EmptyPublishable=0;
	if [ "${PublishableCount}" == "2" ] ;
	then
	    EmptyPublishable=1;
		echo "Tips: No services need to be released."
	else
	    function Print()
		{
			if [ "$1" == "1" ]; then
				echo "$2 will be released."
			fi    
		}

		echo ""
		Print ${ApiPublishable} "Ziya.Api" 
		Print ${WebPublishable} "Ziya.Web" 
	fi

	SyncConfig "${AllPublishable}" "${EmptyPublishable}" "${ApiPublishable}" "${WebPublishable}"

	echo ""
    echo "End analyzing the difference log..."
fi