## ETCD
StorageOS uses etcd to keep cluster consistency. By default StorageOS uses an
embedded installation of etcd. However, this installation permits you
to use services in Kubernetes to reference a non embedded etcd cluster. You can define the
Namespace and Service name in deploy-storageos.sh.

In the directory `etcd-deployment`, there is an example of a 3 node etcd cluster
bootstrap using the etcd Kubernetes operator from https://github.com/coreos/etcd-operator. Follow the instructions in the `etcd-deployment` directory.

> The maintenance of the etcd cluster is out of the scope of StorageOS. It is
> mandatory that the user handle backups, and ensure high availability. The
> deployment of the etcd cluster aims to be an example.

# Deploy StorageOS

Once you have deployed the etcd cluster, run the script `deploy-storageos.sh` to run a StorageOS cluster deployed in its own namespace with a DaemonSet and RBAC support.

The etcd SVC cluster IP is discovered when running the `deploy-storageos.sh` and
populates the ConfigMap `manifests/005_config.yaml_template`.

> By running the `cleanup.sh` the StorageOS cluster will be removed. The data will remain present if you run the deployment script again. Stopping or loosing any node
while StorageOS is not running can corrupt the state of cluster and loose data. 

The manifest yaml files can be found in the manifests dir. There are two kind of files, .yaml and .yaml_template. The templates are used as base to set the API address 
so the StorageClass can connect to the StorageOS cluster, and the JOIN variable to discover cluster nodes that is set to all internal IPs of your Kubernetes cluster. Currently the `deploy-storageos.sh` queries all the nodes' internal IPs of your Kubernetes cluster. If you don't run workloads and StorageOS on the Kubernetes masters add the according label to the query so the JOIN variable doesn't match your master nodes.


## Set the JOIN variable manually

If you want to control what nodes are used to bootstrap StorageOS rather than using all internal
IPs, you can set the JOIN env variable manually. 

The JOIN variable is used for the PODS to discover each other in the cluster. Checkout the different discovery methods in the [documentation](https://docs.storageos.com/docs/install/prerequisites/clusterdiscovery).

Choose one of the methods, for instance, setting the ip of all your nodes that will run StorageOS. 

> You don't actually need to specify all the nodes. Once a new StorageOS node can connect to a member of the cluster the gossip protocol discovers the whole list of members. For high availability, it is recommended to 
> set up as many as possible, so if one node is unavailable at the bootstrap process the next in the list will be queried.

```
sed -i "s:<JOIN>:my_ip1,my_ip2,my_ip3,my_ip4:" manifests/040_daemonsets.yaml_template
./deploy-storageos.sh
```
