#!/bin/bash

oc create -f https://github.com/storageos/cluster-operator/releases/download/v2.4.1/storageos-operator.yaml
oc adm policy add-scc-to-user privileged system:serviceaccount:storageos:storageos-daemonset-sa

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: oc -n storageos-operator get pods${NC}"
