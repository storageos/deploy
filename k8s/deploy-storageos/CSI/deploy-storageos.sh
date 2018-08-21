#!/bin/bash

manifests=./manifests
tmp_file=/tmp/manifest-$RANDOM.yaml

[ -d "$manifests" ] || (echo "manifests dir not found" && exit 1)

JOIN=$(kubectl get nodes -o  jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address  }' |tr ' ' ',';echo)
sed -e "s/<JOIN>/$JOIN/" "$manifests/060-daemonsets.yaml_template" >> "$tmp_file"

kubectl create -f $manifests/ -f $tmp_file

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: kubectl -n storageos get pods${NC}"
