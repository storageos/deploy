#!/usr/bin/env bash

GR='\033[0;32m'
YC='\033[0;33m'
NC='\033[0m' # No Color

# If prometheus-operator directory does not exist then clone it
if [ ! -d prometheus-operator ]; then
    git clone https://github.com/coreos/prometheus-operator.git prometheus-operator
fi

# Install the prometheus-operator
kubectl create -f prometheus-operator/bundle.yaml

# Wait until the operator pod is running before moving on
until $(kubectl get pods -l app.kubernetes.io/name=prometheus-operator --no-headers | awk '{print $3}' | grep -q Running); do
    echo -e "${YC}Waiting for Prometheus operator pod to be running${NC}\n"
    sleep 5
done

# Create the Prometheus CR and StorageOS ServiceMonitor
kubectl create -f ./manifests/prometheus/

echo -e "${GR}Checkout status: kubectl get pods -l app=prometheus${NC}"
