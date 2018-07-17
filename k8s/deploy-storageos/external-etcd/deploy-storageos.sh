#!/bin/bash

manifests=./manifests
tmp_file=/tmp/manifest-$RANDOM.yaml

[ -d "$manifests" ] || (echo "manifests dir not found" && exit 1)

kubectl create -f $manifests/
sleep 2

CLUSTER_IP=$(kubectl -n storageos get svc/storageos -o custom-columns=IP:spec.clusterIP --no-headers=true)
API_ADDRESS=$(echo -n "tcp://$CLUSTER_IP:5705" | base64)
JOIN=$(kubectl get nodes -o  jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address  }' |tr ' ' ',';echo)
ETCD_ADDRESS=$(kubectl -n storageos get svc/etcd-storageos -o custom-columns=IP:spec.clusterIP --no-headers=true)

sed -e "s/<API_ADDRESS>/$API_ADDRESS/" "$manifests/030_interface.yaml_template" >> "$tmp_file"
echo "---" >> "$tmp_file"
sed -e "s/<JOIN>/$JOIN/" -e "s/<ETCD_ADDRESS>/$ETCD_ADDRESS/" "$manifests/040_daemonset.yaml_template" >> "$tmp_file"

kubectl create -f $tmp_file

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: kubectl -n storageos get pods${NC}"
