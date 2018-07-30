# NFS on StorageOS

> Manifests based on the [kubernetes incubator project](https://github.com/kubernetes-incubator/external-storage).

This example shows how to deploy an nfs ganesha based server using StorageOS volumes. The
StateFulset runs one replica that mounts a claimTamplateVolume based pvc using StorageOS class.
Wherever the pod is provisioned, StorageOS makes the data available. Hence everything in /export is
persisted between restarts.

The nfs StateFulSet runs as a Kubernetes storage provisoner, hence volumes created with the
`nfs-provisioner` storageClass will mount volumes via nfs.

## Deploy

```
kubectl create -f manifests/
```

## How To use nfs volumes

### Create a pvc

From `manifests/tests/pvc.yaml`

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nfs
  annotations:
    volume.beta.kubernetes.io/storage-class: "storageos-nfs"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```

### Create pods

Create 4 pods that mount the same pvc. Most likely those 4 pods will be created in different nodes.
Which will help you see that you can mount the same volume via nfs from different K8S nodes. 

```
kubectl create -f manifests/tests/write-pod.yaml
```

Once the 4 pods finish, create the readers.

```
kubectl create -f manifests/tests/read-pod.yaml
```

Checkout the logs of the reader pod to see that 4 files were created. The 4 reader pods will show
the same results as all mount the same volume and list the files in the mounted endpoint. 

```
kubectl logs -lapp=nfs-app
```

You can also exec to the nfs pod and enter /export/VOLUME_ID/ and see the files created by the
write pods.

```
kubectl exec -it --namespace storageos nfs-0 -- /bin/sh
cd /export/pvc-ID/
ls
```

## Cleanup

```
kubectl delete -f manifests/tests -f manifests/
```
