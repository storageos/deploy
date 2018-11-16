#!/bin/bash

echo "Run the following command to have a shell inside your cluster with StorageOS cli"

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}kubectl -n storageos run --image storageos/cli:1.0.0 --restart=Never --env STORAGEOS_HOST=storageos  --env STORAGEOS_USERNAME=storageos --env STORAGEOS_PASSWORD=storageos --command cli -- /bin/sleep 999999 ${NC}"
echo -e "${GR}kubectl -n storageos exec -it cli -- /bin/sh${NC}"

