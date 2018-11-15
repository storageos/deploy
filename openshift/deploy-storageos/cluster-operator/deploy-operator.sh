#!/bin/bash

manifests=./manifests

[ -d "$manifests" ] || (echo "manifests dir not found" && exit 1)

oc create -f $manifests/
oc adm policy add-scc-to-user privileged system:serviceaccount:storageos:storageos-daemonset-sa

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: oc -n storageos-operator get pods${NC}"
