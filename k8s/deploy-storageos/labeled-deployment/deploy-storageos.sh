#!/bin/bash

manifests=./manifests
tmp_file1=/tmp/manifest1-$RANDOM.yaml
tmp_file2=/tmp/manifest2-$RANDOM.yaml

[ -d "$manifests" ] || (echo "manifests dir not found" && exit 1)

kubectl create -f $manifests/
sleep 2

CLUSTER_IP=$(kubectl -n storageos get svc/storageos -o custom-columns=IP:spec.clusterIP --no-headers=true)
API_ADDRESS=$(echo -n "tcp://$CLUSTER_IP:5705" | base64)
JOIN=$(kubectl get nodes -l storageos=compute-only -o  jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address  }' |tr ' ' ',';echo)

sed -e "s/<API_ADDRESS>/$API_ADDRESS/" "$manifests/030_interface.yaml_template" >> "$tmp_file1"
echo "---" >> "$tmp_file1"
sed -e "s/<JOIN>/$JOIN/" "$manifests/040_daemonset-computeonly.yaml_template" >> "$tmp_file1"
sed -e "s/<JOIN>/$JOIN/" "$manifests/045_daemonset_storage.yaml_template" >> "$tmp_file2"

kubectl create -f $tmp_file1

echo "Waiting for compute only nodes to start"
sleep 20

desired=$(kubectl -n storageos get daemonset storageos-computeonly -o custom-columns=_:.status.desiredNumberScheduled --no-headers)
ready=$(kubectl -n storageos get daemonset storageos-computeonly -o custom-columns=_:.status.numberReady --no-headers)

while [ "$ready" -eq "0" ] || [ "$desired" -ne "$ready" ]; do
    echo "Waiting for compute only nodes to start. There are $ready pods ready while $desired desired."
    sleep 4
    desired=$(kubectl -n storageos get daemonset storageos-computeonly -o custom-columns=_:.status.desiredNumberScheduled --no-headers)
    ready=$(kubectl -n storageos get daemonset storageos-computeonly -o custom-columns=_:.status.numberReady --no-headers)
done

kubectl create -f $tmp_file2
