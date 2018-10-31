# Install ETCD 

Example of how to install a etcd cluster using the etcd k8s operator. 

1. Download repo
    ```bash
    git clone https://github.com/coreos/etcd-operator.git
    ```
1. Configure NS, Role and RoleBinding
    ```bash
    export ROLE_NAME=etcd-operator
    export ROLE_BINDING_NAME=etcd-operator
    export NAMESPACE=etcd
    ```
1. Create Namespace
    ```bash
    kubectl create namespace $NAMESPACE
    ```
1. Deploy Operator
    ```bash
    ./etcd-operator/example/rbac/create_role.sh
    kubectl -n $NAMESPACE create -f ./etcd-operator/example/deployment.yaml
    ```
1. Deploy etcd cluster 
    ```bash
    kubectl -n $NAMESPACE create -f ./etcd-cluster-config.yaml
    ```
1. Create SVC to expose ETCD 
    ```bash
    kubectl -n $NAMESPACE create -f ./etcd-svc.yaml
    ```
## More details

Refer to the operator page for more details https://github.com/coreos/etcd-operator.
