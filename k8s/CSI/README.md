# CSI example

Follow this example to install StorageOS as a DaemonSet with CSI integration. 

## Set the JOIN variable

The JOIN variable is used for the PODS to discover each other in the cluster. Checkout the different discovery methods in the [documentation](https://docs.storageos.com/docs/install/prerequisites/clusterdiscovery).

Choose one of the methods, for instance, setting the ip of all your nodes that will run StorageOS. 

> You don't actually need to specify all the nodes. Once a new StorageOS node can connect to a member of the cluster the gossip protocol discovers the whole list of members. For high availability, it is recommended to 
> set up as many as possible, so if one node is unavailable at the bootstrap process the next in the list will be queried.

```
sed -i "s:<JOIN>:my_ip1,my_ip2,my_ip3,my_ip4:" manifests/060-daemonsets.yaml
```

## Deploy StorageOS

```
kubectl create -f manifests/
```

