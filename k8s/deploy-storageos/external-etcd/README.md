# Deploy StorageOS

Run the script `deploy-storageos.sh` to run a StorageOS cluster deployed in its own namespace with a DaemonSet and RBAC support, using the etcd nodes defined in `manifests/025_etcd_service.yaml`.

> By running the `cleanup.sh` the StorageOS cluster will be removed. The data will remain present if you run the deployment script again. Stopping or loosing any node
while StorageOS is not running can corrupt the state of cluster and loose data. 

The manifest yaml files can be found in the manifests dir. There are two kind of files, .yaml and .yaml_template. The templates are used as base to set the API address 
so the StorageClass can connect to the StorageOS cluster, and the JOIN variable to discover cluster nodes that is set to all internal IPs of your Kubernetes cluster. 

## External ETCD cluster

StorageOS recommends using external etcd for large clusters and for those that
change its topology frequently, such as cloud installations with frequent scale
out and scale down of the nodes.

If you run an ETCD cluster out of the scope of Kubernetes, you can reference to
it by setting the addresses of your etcd nodes at
`manifests/025_etcd_service.yaml`. That k8s service decouples the application
from the external services. However, if you prefer to set the ips without TCP
balancing, you can change the SVC name in the file `manifests/005_config` for
the ips in format 'ip1:port,ip2:port,'.

> Only versions of etcd server 3.0 and above are supported.

After that, you can proceed to execute the script `deploy-storageos.sh` as usual.
