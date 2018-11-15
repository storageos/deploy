# Deploy StorageOS

Run the script `deploy-storageos.sh` to run a StorageOS cluster selecting which nodes of your cluster either run in compute only or storage mode.

> By running the `cleanup.sh` the StorageOS cluster will be removed. The data will remain present if you run the deployment script again. Stopping or loosing any node
while StorageOS is not running can corrupt the state of cluster and loose data. 

The manifest yaml files can be found in the manifests dir. There are two kind of files, .yaml and .yaml_template. The templates are used as base to set the API address 
so the StorageClass can connect to the StorageOS cluster, and the JOIN variable to discover cluster nodes that is set to all internal IPs of your Kubernetes cluster. 

## Label Nodes

Label each node that must run StorageOS in compute only with the tag `storageos=compute-only`

```
kubectl label node MY_NODE storageos=compute-only 
```

Label each node that must run StorageOS in storage mode with the tag storageos=storage

```
kubectl label node storageos=storage
```

> Nodes not labeled don't run StorageOS in this installation procedure. Pods running in nodes where StorageOS is not present cannot mount volumes managed by StorageOS. The labels are mutual exclusive, so a node can only be in compute-only or in storage mode.

## Deploy StorageOS

Once the nodes are labeled run the deployment script.

```
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
