#!/bin/bash

set -e

# Import external functions
chmod +x ./devops/PipeLines/Functions.core.sh
source ./devops/PipeLines/Functions.core.sh

GetSolutionName SolutionName

echo "Begin building..."
dotnet build ${SolutionName}
echo "Build completed."