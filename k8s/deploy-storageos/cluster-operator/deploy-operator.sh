#!/bin/bash

kubectl create -f https://github.com/storageos/cluster-operator/releases/download/v2.1.0/storageos-operator.yaml


GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: kubectl -n storageos-operator get pods${NC}"
