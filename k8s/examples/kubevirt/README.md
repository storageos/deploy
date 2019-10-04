# Kubevirt on Kubernetes with StorageOS Persistent Storage

This example shows how to deploy Kubevirt on Kubernetes with StorageOS
persistent volumes being used to provide persistent storage the Kubevirt
virtual machines. These files deploy Kubevirt and the associated Containerized
Data Importer (CDI) that can be used *AFTER* a StorageOS cluster has been
created. For more information on how to install a StorageOS cluster please see
[the StorageOS
documentation](https://docs.storageos.com/docs/introduction/quickstart) for
more information.

Deploying Kubevirt using StorageOS offers multiple benefits. Kubevirt can spin
up Virtual Machines as Kubernetes pods, using images on StorageOS persistent
volumes. Doing this allows the VirtualMachine data to persist restarts and
rescheduling. Using StorageOS [volume
replicas](https://docs.storageos.com/docs/concepts/replication) also allows for
failure of nodes holding the PersistentVolume without interrupting the VM
running off the PersistentVolume. CDI can also be used to prepare
StorageOS volumes with disk images in an automated fashion. Simply by declaring
that a VirtualMachine will use a DataVolume and providing the disk image URL, a
StorageOS volume can be dynamically provisioned and automatically prepared with
the disk image.

## Prerequisites

Please see the [ Kubevirt installation instructions
](https://kubevirt.io/user-guide/docs/latest/administration/intro.html)  to
ensure the Kubevirt prerequisites have been met. 

As part of this installation it is assumed that you are running a Kubernetes
cluster on virtual machines. As such, either nested virtualization  or hardware
emulation need to be enabled. For ease of installation we have enabled hardware
emulation.

> If your VMs support nested virtualization then edit the Kubevirt `configMap`
> `./kubevirt-install/10-cm.yam` , removing the line for more
> information.`debug.useEmulation: "true"`.

## Deploy

In order to deploy Kubevirt you just need to clone this repository and use
kubectl to create the Kubernetes objects.

```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos/k8s/examples/kubevirt
$ kubectl create -f ./kubevirt-install
```
Once this is done you can check that the Kubevirt pods are running.

```bash
$ kubectl get pods -w -n kubevirt
   NAME                               READY   STATUS    RESTARTS   AGE
   virt-api-57546d479b-p26d4          1/1     Running   0          1m
   virt-api-57546d479b-zs5dw          1/1     Running   0          1m
   virt-controller-56b5498854-7xsfz   1/1     Running   1          1m
   virt-controller-56b5498854-bz559   1/1     Running   1          1m
   virt-handler-6z4kq                 1/1     Running   0          1m
   virt-handler-7szhl                 1/1     Running   0          1m
   virt-handler-jmm6w                 1/1     Running   0          1m
   virt-operator-79c9bdd859-8xq98     1/1     Running   0          1m
   virt-operator-79c9bdd859-kfjz6     1/1     Running   0          1m
```

Once Kubevirt is running install CDI.

```bash
$ kubectl create -f ./cdi
```

Check that the CDI pods are running correctly.

```bash
$ kubectl get pods -n cdi
NAME                              READY   STATUS    RESTARTS   AGE
cdi-apiserver-8668f888df-s6pp4    1/1     Running   0          1m
cdi-deployment-5cf794896b-whh4j   1/1     Running   0          1m
cdi-operator-5887f96c-dz2hg       1/1     Running   0          1m
cdi-uploadproxy-97fbbfcbf-6f9xs   1/1     Running   0          1m
```

Now that CDI and Kubevirt are running `VirtualMachines` can be created. As the
vm-cirros.yaml manifest creates a `VirtualMachine` that uses a `DataVolume`, CDI
will create a StorageOS backed PVC and download the image that the
`VirtualMachineInstance` (VMI) will boot from onto the PVC.

```bash
$ kubectl create -f ./vm-cirros.yaml
```

Check that the `VMI` is running and attempt to connect to the
console.

> N.B. The `VMI` will only be created after CDI has downloaded
> the Cirros disk image onto a StorageOS persistent volume so depending on your
> connection speed this may take some time.

```bash
$ kubectl get vmi
NAME     AGE   PHASE     IP            NODENAME
cirros   1m   Running   10.244.2.12   ip-10-1-10-154.storageos.net
$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
virt-launcher-cirros-drqhr   1/1     Running   0          1m
```

This example uses the [virtctl
kubectl](https://kubevirt.io/quickstart_minikube/#install-virtctl) plugin in
order to connect to the VirtualMachine console. The escape sequence ^] is ctrl
+ ]

```bash
$ kubectl virt console cirros
Successfully connected to cirros console. The escape sequence is ^]
login as 'cirros' user. default password: 'gocubsgo'. use 'sudo' for root.
cirros login: cirros
Password:
$
```

## Live Migration

Kubevirt allows for the live migration of `VMIs` from one node
to another while workloads running inside the virtual machines continue to run.
VirtualMachineInstanceMigration resources are used to kick off migrations. In
order to migrate a virtual machine instance, the `VMI`s
volumes must have a `ReadWriteMany` AccessMode. StorageOS provides
`ReadWriteMany` volumes that can be used for this purpose.

Create the migratable VirtualMachine and verify that the `VMI` is running
```bash
$ kubectl create -f ./k8s/examples/kubevirt/migration/vm-cirros.yaml
$ kubectl get vmi
NAME     AGE   PHASE     IP            NODENAME
cirros   1m    Running   10.244.4.12   ip-10-1-10-174.storageos.net
```

Connect to the console using virtctl and start running a bash loop
```bash
$ kubectl virt console cirros
$ for i $(seq 300); do echo $i && echo $i >> counter.txt && sleep 1; done
```

You can leave the console running and open a new terminal window, or leave the
console, in order to create the VirtualMachineInstanceMigration.

```bash
$ kubectl create -f ./k8s/examples/kubevirt/migration/migration-job.yaml
```

## Cloning Volumes

CDI allows for images to be cloned using a DataVolume manifest. Verify that the
cirros pvc, created as part of the vm-cirros.yaml file, exists before
attempting to clone the volume.

> N.B. Ensure that the `VMI` is stopped before continuing!

```bash
$ kubectl get pvc
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
cirros              Bound    pvc-f4833060-5a77-420c-927e-6bc518d9df3c   12Gi       RWO            fast           1m
```

Once the PVC's existence is confirmed then create a new DataVolume that uses the cirros PVC as its source.

```bash
$ kubectl create -f ./cloned.yaml
```

You'll see that a cdi-upload-cloned-datavolume pod is created and then a
cdi-clone-source pod is created. The cdi-source pod mounts the original cirros
volume and sends the contents of the volume to the cdi-upload pod. The
cdi-upload pod creates and mounts a new PVC and writes the contents of the
driginal volume to it.
