#!/bin/bash
set -e
IFS=$'\n\n'

# 001 Continuous integration image to registry.
bash ./devops/PipeLines/Creation/001_CI.sh

# 002 Create config information to k8s's configmap.
bash ./devops/PipeLines/Creation/002_CreateConfig.sh

# 003 Release major to k8s's cluster. 
bash ./devops/PipeLines/Creation/003_ReleaseMajor.sh

# 004 Create gateway route.
bash ./devops/PipeLines/Creation/Gateways/Kong/004_CreateGatewayRoute.sh