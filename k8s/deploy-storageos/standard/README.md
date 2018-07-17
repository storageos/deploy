# Deploy StorageOS

Run the script `deploy-storageos.sh` to run a StorageOS cluster deployed in its own namespace with a DaemonSet and RBAC support.

> By running the `cleanup.sh` the StorageOS cluster will be removed. The data will remain present if you run the deployment script again. Stopping or loosing any node
while StorageOS is not running can corrupt the state of cluster and loose data. 

The manifest yaml files can be found in the manifests dir. There are two kind of files, .yaml and .yaml_template. The templates are used as base to set the API address 
so the StorageClass can connect to the StorageOS cluster, and the JOIN variable to discover cluster nodes that is set to all internal IPs of your Kubernetes cluster. 


