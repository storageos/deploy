#!/bin/env bash

MANIFESTS=./manifests
NAMESPACE=${NAMESPACE:-default}

if ! $(oc get ns --no-headers | grep -q ${NAMESPACE}); then
    oc create ns ${NAMESPACE}
fi

[ -d "$MANIFESTS"  ] || (echo "manifests dir not found" && exit 1)

oc -n ${NAMESPACE} create -f ${MANIFESTS}
oc adm policy add-scc-to-user mysql system:serviceaccount:${NAMESPACE}:mysql
sleep 2

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: oc -n ${NAMESPACE} get pods -l app=mysql${NC}"
