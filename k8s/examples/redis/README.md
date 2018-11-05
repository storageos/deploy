# Redis Server on Kubernetes with StorageOS persistent Storage

This example shows an example of how to deploy Redis Server on Kubernetes with
Redis data being written to a StorageOS persistent volume. The files create a
stateful set that can be used *AFTER* a StorageOS cluster has been created. For
more information on how to install a StorageOS cluster please see
[the StorageOS documentation](https://docs.storageos.com/docs/introduction/quickstart)
for more information.

## Deploy

In order to deploy Redis you just need to clone this repostiory and use
kubectl to create the Kubernetes objects. 

```bash
git clone https://github.com/storageos/deploy.git storageos
cd storageos
kubectl create -f ./k8s/examples/redis
```
Once this is done you can check that a redis pod is running

```bash
kubectl get pods -w -l app=redis
   NAME        READY    STATUS    RESTARTS    AGE
   redis-0     1/1      Running    0          1m
```
Connect to the Redis client pod and connect to the Redis server through the
service
```bash
$ kubectl exec -it redis-0 -- redis-cli -a password
Warning: Using a password with '-a' option on the command line interface may not be safe.
127.0.0.1:6379> CONFIG GET maxmemory
1) "maxmemory"
2) "0"
```
