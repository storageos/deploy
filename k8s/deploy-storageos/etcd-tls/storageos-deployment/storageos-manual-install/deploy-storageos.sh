#!/bin/bash

manifests=./manifests
tmp_file=/tmp/manifest-$RANDOM.yaml
cert_dir=../certs

ETCD_NS=etcd
ETCD_SVC=storageos-etcd-cluster-client
ETCD_ADDRESS="$ETCD_SVC.$ETCD_NS.svc"

[ -d "$manifests" ] || (echo "manifests dir not found" && exit 1)

kubectl create -f $manifests/
sleep 2

#Create secrets from the certificate files that were generated.
kubectl create secret generic etcd-client-tls --from-file="$cert_dir/etcd-client-ca.crt" --from-file="$cert_dir/etcd-client.crt" --from-file="$cert_dir/etcd-client.key" -n storageos

#Create the apiAddress that's used in the storageos-api secret
CLUSTER_IP=$(kubectl -n storageos get svc/storageos -o custom-columns=IP:spec.clusterIP --no-headers=true)
API_ADDRESS=$(echo -n "tcp://$CLUSTER_IP:5705" | base64)
#Create the JOIN value that is used in the StorageOS daemonset
JOIN=$(kubectl get nodes -o  jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address  }' |tr ' ' ',';echo)

#Replace templated values
sed -e "s/<ETCD_ADDR>/$ETCD_ADDRESS/" "$manifests/005_config.yaml_template" >> "$tmp_file"
echo "---" >> "$tmp_file"
sed -e "s/<API_ADDRESS>/$API_ADDRESS/" "$manifests/030_interface.yaml_template" >> "$tmp_file"
echo "---" >> "$tmp_file"
sed -e "s/<JOIN>/$JOIN/" "$manifests/040_daemonset.yaml_template" >> "$tmp_file"

kubectl create -f $tmp_file

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: kubectl -n storageos get pods${NC}"
