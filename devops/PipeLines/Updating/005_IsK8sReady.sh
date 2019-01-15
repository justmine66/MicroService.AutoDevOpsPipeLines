#!/bin/bash

IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh

# global variable
RollEnvironmentOf Environment

#1: ready, 0: not ready.
declare ready=0

GetNameSpace namespace

while [ $((${ready})) == 0 ]
do
    sleep 10s
	echo ""
	declare allIsReady=1
	for row in $(kubectl -n ${namespace} get deployment)
	do
	    echo ""
		declare name=$(echo "${row}"|awk '{print $1}')
		declare desired=$(echo "${row}"|awk '{print $2}')
		declare current=$(echo "${row}"|awk '{print $3}')
		declare uptodate=$(echo "${row}"|awk '{print $4}')
		declare available=$(echo "${row}"|awk '{print $5}')
		echo "[${Environment}]deployment: ${name}, desired: ${desired}, current: ${current}, uptodate: ${uptodate}, available: ${available}"
		if [ $((${desired})) == $((${current})) -a $((${current})) == $((${uptodate})) -a $((${uptodate})) == $((${available})) ]; then
				echo "[${Environment}]${name} has been ready.";
		else 
			echo "[${Environment}]${name} has been not ready.";
			allIsReady=0
		fi
	done

	if [ $((${allIsReady})) == 1 ]; then
	    ready=1
	fi
done