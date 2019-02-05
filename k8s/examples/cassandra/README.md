# Cassandra on Kubernetes with StorageOS persistent Storage

This example shows an example of how to deploy a three node Cassandra ring on
Kubernetes with Cassandra data being written to a StorageOS backed persistent
volume. The files create a stateful set that can be used *AFTER* a StorageOS
cluster has been created. For more information on how to install a StorageOS
cluster please see [the StorageOS
documentation](https://docs.storageos.com/docs/introduction/quickstart) for
more information.

## Deploy

In order to deploy Cassandra you just need to clone this repostiory and use
kubectl to create the Kubernetes objects.

```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos
$ kubectl create -f ./k8s/examples/cassandra
```
Once this is done you can check that three Cassandra pods are running. Because
Cassandra is being deployed as a StatefulSet, pod cassandra-1 will only be
created once cassandra-0 is ready. 

```bash
$ kubectl get pods -w -l app=cassandra
NAME          READY   STATUS    RESTARTS   AGE
cassandra-0   1/1     Running   0          8m32s
cassandra-1   1/1     Running   0          7m51s
cassandra-2   1/1     Running   0          6m36s 

```

Connect to a Cassandra pod and connect to the Cassandra server through the
service.

```bash
$ kubectl exec -it cassandra-0 -- cqlsh cassandra-0.cassandra
Connected to K8Demo at cassandra-0.cassandra:9042.
[cqlsh 5.0.1 | Cassandra 3.11.3 | CQL spec 3.4.4 | Native protocol v4]
Use HELP for help.
cqlsh> SELECT cluster_name, listen_address FROM system.local;

 cluster_name | listen_address
--------------+----------------
       K8Demo |   100.96.7.124

(1 rows)
```
