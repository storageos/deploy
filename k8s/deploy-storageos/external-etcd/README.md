# Deploy StorageOS

Run the script `deploy-storageos.sh` to run a StorageOS cluster deployed in its own namespace with a DaemonSet and RBAC support, using the etcd nodes defined in `manifests/025_etcd_service.yaml`.

> By running the `cleanup.sh` the StorageOS cluster will be removed. The data will remain present if you run the deployment script again. Stopping or loosing any node
while StorageOS is not running can corrupt the state of cluster and loose data. 

The manifest yaml files can be found in the manifests dir. There are two kind of files, .yaml and .yaml_template. The templates are used as base to set the API address 
so the StorageClass can connect to the StorageOS cluster, and the JOIN variable to discover cluster nodes that is set to all internal IPs of your Kubernetes cluster. 

## External ETCD cluster

Set the addresses of your etcd nodes at `manifests/025_etcd_service.yaml`. That k8s service decouples the application from the external services. However, you can define the etcd 
cluster ip coupling the installation by editing the enviromental variables of the StorageOS container at `manifests/040_daemonset.yaml_template`.

> Only versions of etcd server 3.0 and above are supported.
