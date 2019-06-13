#!/bin/bash

MANIFESTS=./manifests
[ -d "$MANIFESTS"  ] || (echo "manifests dir not found" && exit 1)

if [[ -z ${NAMESPACE} ]]; then
    echo "Must set NAMESPACE environment variable" 1>&2
    exit 1
fi

oc -n ${NAMESPACE} delete -f ${MANIFESTS}
sleep 2
