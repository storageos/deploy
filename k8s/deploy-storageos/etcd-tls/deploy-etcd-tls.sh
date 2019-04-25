#!/bin/bash

ETCD_NS=etcd
ROLE_NAME=etcd-operator
ROLE_BINDING_NAME=etcd-operator

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
./etcd-deployment/etcd-operator/example/rbac/create_role.sh --namespace=${ETCD_NS}

# Create the Etcd Operator deployment
kubectl -n $ETCD_NS create -f ./etcd-deployment/etcd-operator/example/deployment.yaml

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

kubectl -n $ETCD_NS create -f ./etcd-deployment/etcd-cluster-config.yaml

GR='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GR}Checkout status: kubectl -n ${ETCD_NS} get pods${NC}"
