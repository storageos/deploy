# StorageOS Installation with mTLS secured etcd

## StorageOS Operator Installation

In order to install StorageOS and get it to use the an external etcd cluster
the StorageOS operator should be used to orchestrate the installation of
StorageOS.

If you have not done so already then install the [StorageOS
Operator](https://docs.storageos.com/docs/reference/cluster-operator/). The
instructions to do so are located in the directory: `../../cluster-operator/`

```bash
(cd ../../../cluster-operator && ./deploy-operator.sh)
```

Once the operator is installed, you need to create the StorageOS secret.

> For more details about the Secret, check out the cluster operator README.
```bash
kubectl create -f - <<END
apiVersion: v1
kind: Secret
metadata:
  name: "storageos-api"
  namespace: "default"
  labels:
    app: "storageos"
type: "kubernetes.io/storageos"
data:
  # echo -n '<secret>' | base64
  apiUsername: c3RvcmFnZW9z
  apiPassword: c3RvcmFnZW9z
END
```

## Deploy StorageOS

Create the StorageOS Cluster Resource located in this folder.

1. Create the StorageOS Cluster resource
    ```bash
    kubectl create -f storageoscluster_cr.yaml
    ```
1. Verify that StorageOS pods are starting
    ```bash
   kubectl -n storageos get pods
    ```

# Cleaning up

In order to remove the StorageOS installation simply delete the StorageOS
Cluster resource that was created.

```bash
kubectl delete stos storageos-cluster
```
