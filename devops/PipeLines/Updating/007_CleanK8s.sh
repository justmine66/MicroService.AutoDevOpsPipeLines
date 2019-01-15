#!/bin/bash

IFS=$'\n\n'

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh

# global variable
RollEnvironmentOf Environment

GetNameSpace namespace

echo "[${Environment}]Begin cleaning..."
# Remove the heading line.
declare replicas=$(kubectl -n ${namespace} get rs|awk 'NR > 1')
for row in $replicas
do
        declare name=$(echo "${row}"|awk '{print $1}')
        declare desired=$(echo "${row}"|awk '{print $2}')
        declare current=$(echo "${row}"|awk '{print $3}')
        declare ready=$(echo "${row}"|awk '{print $4}')
#       echo "replica set: ${name}, desired: ${desired}"
        if [ $((${desired})) == 0 -a $((${current})) == 0 -a $((${ready})) == 0 ]; then
#               echo ${name}
            kubectl -n ${namespace} delete rs ${name} --grace-period=0 --force
        fi
done

echo '[${Environment}]Clean completed.'