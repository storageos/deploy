#!/bin/bash

echo "Run the following command to have a shell inside your cluster with StorageOS cli"

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}kubectl -n storageos run --image storageos/cli:1.0.0-rc2 --rm --restart=Never --env STORAGEOS_HOST=\$(kubectl get svc/storageos --namespace storageos -o custom-columns=IP:spec.clusterIP --no-headers=true)  --env STORAGEOS_USERNAME=storageos --env STORAGEOS_PASSWORD=storageos --command -it storageos-cli -- /bin/sh${NC}"

