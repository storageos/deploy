#!/bin/bash

ETCD_NS=etcd
ROLE_NAME=etcd-operator
ROLE_BINDING_NAME=etcd-operator
NAMESPACE=etcd


# Install the Etcd Operator
# Begin by cloning the Etcd operator repository if it doesn't already exist
if [ -d ./etcd-deployment/etcd-operator ]; then
    printf "etcd-operator repository already exists. Moving on to etcd-operator installation\n"
else
    git clone https://github.com/coreos/etcd-operator.git ./etcd-deployment/etcd-operator
fi

# Create the namespace that the Etcd operator and Etcd will be installed into
kubectl create namespace "$ETCD_NS"

# Create the Cluster roles the Etcd Operator requires
# ./etcd-deployment/etcd-operator/example/rbac/create_role.sh --namespace=${ETCD_NS}

# Create the Etcd Operator deployment
# kubectl -n $ETCD_NS create -f ./etcd-deployment/etcd-operator/example/deployment.yaml
# Create ClusterRole and ClusterRoleBinding
kubectl -n $NAMESPACE create -f-<<END
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: etcd-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: etcd-operator
subjects:
- kind: ServiceAccount
  name: default
  namespace: $NAMESPACE
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: etcd-operator
rules:
- apiGroups:
  - etcd.database.coreos.com
  resources:
  - etcdclusters
  - etcdbackups
  - etcdrestores
  verbs:
  - "*"
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - "*"
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - endpoints
  - persistentvolumeclaims
  - events
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - "*"
# The following permissions can be removed if not using S3 backup and TLS
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
---
END

# Create etcd operator Deployment
kubectl -n $NAMESPACE create -f-<<END
apiVersion: apps/v1
kind: Deployment
metadata:
  name: etcd-operator
spec:
  replicas: 3
  selector:
    matchLabels:
      name: etcd-operator
  template:
    metadata:
      labels:
        name: etcd-operator
    spec:
      containers:
      - name: etcd-operator
        image: quay.io/coreos/etcd-operator:v0.9.4
        command:
        - etcd-operator
        env:
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
END

echo "Waiting for the etcd operator to start"
sleep 5


# Creating Etcd certificates
certs=./certs
json=./certs/json

[[ -d "$certs" && -d "$json" ]] || (echo "certs or json directories not found" && exit 1)

# Create the CA certs
./bin/cfssl gencert -initca "$json/ca-csr.json" | ./bin/cfssljson -bare "$certs/ca" -

# Create the server certs
./bin/cfssl gencert -ca="$certs/ca.pem" -ca-key="$certs/ca-key.pem" -config="$json/ca-config.json" -profile=server "$json/server.json" | ./bin/cfssljson -bare "$certs/server"

# Create the peer certs
./bin/cfssl gencert -ca="$certs/ca.pem" -ca-key="$certs/ca-key.pem" -config="$json/ca-config.json" -profile=peer "$json/peer.json" | ./bin/cfssljson -bare "$certs/peer"

# Create the client certs
./bin/cfssl gencert -ca="$certs/ca.pem" -ca-key="$certs/ca-key.pem" -config="$json/ca-config.json" -profile=client "$json/client.json" | ./bin/cfssljson -bare "$certs/client"

# Rename client certs so they are consistent with Etcd Operator docs
# https://github.com/coreos/etcd-operator/blob/master/doc/user/cluster_tls.md
mv "$certs/client.pem" "$certs/etcd-client.crt"
mv "$certs/client-key.pem" "$certs/etcd-client.key"
cp "$certs/ca.pem" "$certs/etcd-client-ca.crt"

mv "$certs/server.pem" "$certs/server.crt"
mv "$certs/server-key.pem" "$certs/server.key"
cp "$certs/ca.pem" "$certs/server-ca.crt"

mv "$certs/peer.pem" "$certs/peer.crt"
mv "$certs/peer-key.pem" "$certs/peer.key"
mv "$certs/ca.pem" "$certs/peer-ca.crt"

# Remove unused *.csr files
# Remove ca-key.pem as it exists as *-ca.crt
rm $certs/*.csr $certs/ca-key.pem

# Create secrets in the ETCD_NS namespace where etcd will be installed
kubectl create secret generic etcd-peer-tls --from-file="$certs/peer-ca.crt" --from-file="$certs/peer.crt" --from-file="$certs/peer.key" -n "$ETCD_NS"
kubectl create secret generic etcd-server-tls --from-file="$certs/server-ca.crt" --from-file="$certs/server.crt" --from-file="$certs/server.key" -n "$ETCD_NS"
kubectl create secret generic etcd-client-tls --from-file="$certs/etcd-client-ca.crt" --from-file="$certs/etcd-client.crt" --from-file="$certs/etcd-client.key" -n "$ETCD_NS"

# kubectl -n $ETCD_NS create -f ./etcd-deployment/etcd-cluster-config.yaml

# Create etcd CustomResource
kubectl -n $NAMESPACE create -f- <<END
apiVersion: "etcd.database.coreos.com/v1beta2"
kind: "EtcdCluster"
metadata:
  name: "storageos-etcd-cluster"
spec:
  size: 3
  version: "3.4.9"
  TLS:
    static:
      member:
        peerSecret: etcd-peer-tls
        serverSecret: etcd-server-tls
      operatorSecret: etcd-client-tls
  pod:
    etcdEnv:
    - name: ETCD_QUOTA_BACKEND_BYTES
      value: "2589934592"  # ~2 GB
    - name: ETCD_AUTO_COMPACTION_MODE
      value: "revision"
    - name: ETCD_AUTO_COMPACTION_RETENTION
      value: "100"
#  For relevant clusters, you want guaranteed QoS "requests == limits"
#    requests:
#      cpu: 2
#      memory: 4G
#    limits:
#      cpu: 2
#      memory: 4G
    resources:
      requests:
        cpu: 200m
        memory: 300Mi
    securityContext:
      runAsNonRoot: true
      runAsUser: 9000
      fsGroup: 9000
#  Tolerations example
#    tolerations:
#    - key: "role"
#      operator: "Equal"
#      value: "etcd"
#      effect: "NoExecute"
    # affinity:
    #   podAntiAffinity:
    #     preferredDuringSchedulingIgnoredDuringExecution:
    #     - weight: 100
    #       podAffinityTerm:
    #         labelSelector:
    #           matchExpressions:
    #           - key: etcd_cluster
    #             operator: In
    #             values:
    #             - storageos-etcd
    #         topologyKey: kubernetes.io/hostname
END

echo "Check the status of the etcd cluster with:"
echo -e "\t kubectl -n $NAMESPACE get pod"

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: kubectl -n ${ETCD_NS} get pods${NC}"
