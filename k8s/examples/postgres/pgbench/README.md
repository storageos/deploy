# Benchmarking PostgreSQL on Kubernetes with StorageOS persistent Storage

This example shows an example of how PostgreSQL can be benchmarked on
Kubernetes using PGBench. The files create a PostgreSQL stateful set that can
be used *AFTER* a StorageOS cluster has been created. An individual PGBench pod
is also created.

## Deploy

In order to deploy PostgreSQL you just need to clone this repository and use
kubectl to create the Kubernetes objects. 

```bash
git clone https://github.com/storageos/deploy.git storageos
cd storageos
```

In order to run the PostgreSQL pod a node needs to be labelled with
`app=postgres`. This node will run the PostgreSQL pod and host the StorageOS
volume. Benchmarking PostgreSQL while it is using a local StorageOS master
volume yields the best performance.

```bash
kubectl label node <NODE_NAME> app=postgres
```

Edit the 20-postgres-statefulset.yaml manifest to set the
`storageos.com/hint.master` label to the node that was just labelled. Then
create the statefulset.

```bash
kubectl create -f ./k8s/examples/postgres/pgbench
```
Once this is done you can check that a postgres pod is running

```bash
$ kubectl get pods -w -l app=postgres
   NAME           READY    STATUS    RESTARTS    AGE
   postgres-0     1/1      Running    0          1m
```

Use the StorageOS CLI or the GUI to check that the master volume location and
the mount location are the same. 
```bash
$ kubectl -n storageos exec -it cli -- storageos volume ls
```

Exec into the pgbench container and run pgbench

```bash
$ kubectl exec -it pgbench -- bash -c '/opt/cpm/bin/start.sh'
```
