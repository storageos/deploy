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


