#!/bin/bash

manifests=./manifests

[ -d "$manifests" ] || (echo "manifests dir not found" && exit 1)

kubectl create -f $manifests/

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: kubectl -n storageos-operator get pods${NC}"
