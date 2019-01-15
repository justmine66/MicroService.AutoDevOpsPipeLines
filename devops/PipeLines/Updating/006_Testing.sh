#!/bin/bash

set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh

# global variable
RollEnvironmentOf Environment

echo "[${Environment}]Begin testing..."
declare dir='./test/ServicesTests' 
for prefix in `ls ${dir}|xargs -d '/'`
do
    dotnet test "${dir}/${prefix}/${prefix}.csproj"
done
echo "[${Environment}]Test completed."