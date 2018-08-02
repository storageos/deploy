# NFS on StorageOS

> Manifests based on the [kubernetes incubator project](https://github.com/kubernetes-incubator/external-storage).

This example shows how to deploy an NFS Ganesha based server using StorageOS volumes. The
StateFulset runs one replica that mounts a claimTamplateVolume based PVC using StorageOS class.
Wherever the pod is provisioned, StorageOS makes the data available. Hence everything in
/export/partitionXX is persisted between restarts.

The NFS StateFulSet runs as a Kubernetes storage provisoner, hence volumes created with the
`nfs-provisioner` storageClass will mount volumes via NFS.

## Deploy

Define how many StorageOS volumes will persist your NFS volumes by editing `manifests/220-statefulet.yaml` claims and where to mount them (.spec.template.spec.containers[0].volumeMounts and .spec.volumeClaimTemplates). By default, 5 StorageOS volumes will be created, 4 with 30Gi each and mounted in the container `/export/partitionX`. The storage provisioner will allocate the data of your NFS volumes under /export/partitionX/pvc-id-of-the-vol-in-k8s. Where the partition is defined when you crete the PVC by setting a label (see example below). 1 StorageOS volume is allocated with 1Gi to persist the dynamic ganesha settings, stored in /export/ganesha.

```
./deploy-nfs-provisioner.sh
```

## How To use NFS volumes

### Create a PVC

From `manifests/tests/part3_pvc1.yaml`

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nfs-vol-3a
  labels:
    partition: partition3
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

Create 4 pods that mount the same PVC. Most likely those 4 pods will be created in different nodes.
Which will help you see that you can mount the same volume via NFS from different K8S nodes. 

```
kubectl create -f manifests/tests/write-pod.yaml
```

Once the 4 pods finish, create the reader.

```
kubectl create -f manifests/tests/read-pod.yaml
```

Checkout the logs of the reader pod to see that 4 files were created. The 4 reader pods will show
the same results as all mount the same volume and list the files in the mounted endpoint. 

```
kubectl logs -lapp=nfs-app
```

You can also exec to the nfs pod and enter /export/partitionX/VOLUME_ID/ and see the files created by the
write pods.

```
kubectl exec -it --namespace storageos nfs-0 -- /bin/sh
cd /export/partition3/pvc-ID/
ls
```

## Cleanup

```
./cleanup.sh
```
