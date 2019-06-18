#!/usr/bin/env bash

GR='\033[0;32m'
YC='\033[0;33m'
NC='\033[0m' # No Color

# If grafana manifests directory does not exist then exit
if [ ! -d ./manifests/grafana ]; then
    echo "No ./manifests/grafana directory exists!"
fi

# Create the Prometheus CR and StorageOS ServiceMonitor
kubectl create -f ./manifests/grafana/

echo -e "${GR}Checkout status: kubectl get pods -l app=grafana${NC}"
