#!/bin/bash

ETCD_NS=etcd
ROLE_NAME=etcd-operator
ROLE_BINDING_NAME=etcd-operator
ETCD_OPERATOR_ROOT="./etcd-deployment/etcd-operator"

# Do not delete etcd if StorageOS is running as this will destroy the StorageOS
# cluster
if kubectl -n storageos get pods 2>/dev/null | grep -q "STATUS"; then
    printf "\e[31m Pods are running in the StorageOS namespace. Removing etcd resources will break the cluster so run ./storageos-deployment/cleanup.sh first\e[0m"
    exit 1
fi

# Delete everything from ETCD_NS
kubectl delete -n ${ETCD_NS} all --all --now

# Remove Etcd Operator RBAC roles
sed -e "s/<ROLE_NAME>/${ROLE_NAME}/g" -e "s/<NAMESPACE>/${ETCD_NS}/g" "${ETCD_OPERATOR_ROOT}/example/rbac/cluster-role-template.yaml" | kubectl -n ${ETCD_NS} delete -f -

sed -e "s/<ROLE_NAME>/${ROLE_NAME}/g" -e "s/<ROLE_BINDING_NAME>/${ROLE_BINDING_NAME}/g" -e "s/<NAMESPACE>/${ETCD_NS}/g" \
    "${ETCD_OPERATOR_ROOT}/example/rbac/cluster-role-binding-template.yaml" | kubectl -n ${ETCD_OPERATOR_ROOT} delete -f -

# Delete ETCD_NS  namespace
kubectl delete namespace ${ETCD_NS}

# Delete certificates
echo "Deleting certificate files"
find certs/ -maxdepth 1 -type f | xargs -I{} -exec rm {}

