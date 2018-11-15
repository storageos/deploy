# Kubernetes Requirements

This installation method should only be used for Kubernetes versions < 1.12.
If you are using Kuberenetes 1.12+ then please perform a helm
installaltion instead. Please see our documentation [here]
(https://docs.storageos.com/docs/platforms/kubernetes/install/1.12) for more
information.

> If you do perform an installation with this example on 1.12 Kubernetes will be
> unable to mount StorageOS volumes into containers. 

# CSI example

Follow this example to install StorageOS as a DaemonSet with CSI integration. 


## Deploy StorageOS

Run the script `deploy-storageos.sh` to run a StorageOS cluster deployed in its own namespace with a DaemonSet and RBAC support using CSI (Container Storage Interface).

> By running the `cleanup.sh` the StorageOS cluster will be removed. The data will remain present if you run the deployment script again. Stopping or loosing any node
while StorageOS is not running can corrupt the state of cluster and loose data. 

The manifest yaml files can be found in the manifests dir. There are two kind of files, .yaml and .yaml_template. The template is used as base to set the JOIN variable to discover cluster nodes. Currently the `deploy-storageos.sh` queries all the nodes' internal IPs of your Kubernetes cluster. If you don't run workloads and StorageOS on the Kubernetes masters add the according label to the query so the JOIN variable doesn't match your master nodes.

## Set the JOIN variable manually

If you want to control what nodes are used to bootstrap StorageOS rather than using all internal
IPs, you can set the JOIN env variable manually. 

The JOIN variable is used for the PODS to discover each other in the cluster. Checkout the different discovery methods in the [documentation](https://docs.storageos.com/docs/install/prerequisites/clusterdiscovery).

Choose one of the methods, for instance, setting the ip of all your nodes that will run StorageOS. 

> You don't actually need to specify all the nodes. Once a new StorageOS node can connect to a member of the cluster the gossip protocol discovers the whole list of members. For high availability, it is recommended to 
> set up as many as possible, so if one node is unavailable at the bootstrap process the next in the list will be queried.

```
sed -i "s:<JOIN>:my_ip1,my_ip2,my_ip3,my_ip4:" manifests/060-daemonsets.yaml_template
./deploy-storageos.sh
```
## Set ETCD endpoint

StorageOS recommends using external etcd for large clusters and for those that change its topology
frequently, such as cloud installations with frequent scale out and scale down of the nodes.

By default StorageOS starts with an embedded managed etcd.

To deploy StorageOS using an external etcd, edit the file `manifests/005_config.yaml` removing the
comments of the following lines and changing `<ETCD_ADDR>` for your etcd svc endpoint. For instance,
if you are  running etcd as pods from the
[etcd-as-svc](https://github.com/storageos/deploy/tree/master/k8s/deploy-storageos/etcd-as-svc)
example, you can set `KV_ADDR: 'http://storageos-etcd-client.etcd'` where the address is set to
`SVC.NAMESPACE`.

```bash
data:
  KV_BACKEND: 'etcd'
  KV_ADDR: 'http://<ETCD_ADDR>:2379' # Set your etcd endpoint
```

After that, you can proceed to execute the script `deploy-storageos.sh` as usual.
