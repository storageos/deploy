# StorageOS Installation with mTLS secured etcd

## StorageOS Operator Installation

In order to install StorageOS and get it to use the newly configured etcd
cluster the StorageOS operator should be used to control the installation of
StorageOS. 

If you have not done so already then install the [StorageOS
Operator](https://docs.storageos.com/docs/reference/cluster-operator/). The
instructions to do so are located in the directory: ../../cluster-operator/

Once the operator is installed and the required secret has been created you can
create the StorageOS Cluster Resource located in this folder.

1. Create the StorageOS Cluster resource
    ```bash
    kubectl create -f storageoscluster_cr.yaml
    ```

# Cleaning up

In order to remove the StorageOS installation simply delete the StorageOS
Cluster resource that was created.

```bash
kubectl delete stos storageos-cluster 
```

# Alternative Installation Method

You can also install StorageOS using yaml manifests. See the README.md in
./storageos-manual-instal/
