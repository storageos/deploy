# Fencing StatefulSets on Kubernetes with StorageOS

This example shows an example of how to lower the time to recover for a MySQL
StatefulSet on Kubernetes with StorageOS fencing, in the case of node failure.
Normally StatefulSet pods are not rescheduled by Kubernetes when nodes become
unavailable due to the guarantee of StatefulSet pod uniqueness.

For more information regarding fencing please see the [StorageOS fencing
documentation](https://docs.storageos.com/docs/concepts/fencing).

## Deploy

In order to deploy MySQL you just need to clone this repository and use
kubectl to create the Kubernetes objects.

```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos
$ kubectl create -f ./k8s/examples/fencing
```
If you inspect the StatefulSet manifest you'll see that two StorageOS labels
are applied to the pod. `storageos.com/replicas` and `storageos.com/fenced`
labels are required for fencing to work. In order to fence a pod it must; mount
at least one StorageOS volume, all StorageOS volumes mounted by the pod must
have a healthy replica and `DISABLE_FENCING` is not set.

Once this is done you can check that a mysql pod is running
```bash
$ kubectl get pods -w -l app=mysql
   NAME        READY    STATUS    RESTARTS    AGE
   client      1/1      Running    0          1m
   mysql-0     1/1      Running    0          1m
```

Connect to the MySQL client pod and connect to the MySQL server through the
service.
```bash
$ kubectl exec -it client -- mysql -h mysql-0.mysql -u root
mysql> create database shop;
mysql> use shop;
mysql> create table books (title VARCHAR(256), price decimal(4,2));
mysql> insert into books value ('Gates of Fire', 13.99);
mysql> select * from books
+---------------+-------+
| title         | price |
+---------------+-------+
| Gates of Fire | 13.99 |
+---------------+-------+
1 row in set (0.00 sec)
```

## Node Failure

Check what node the mysql-0 pod is running on and make that node unavailable
e.g. shutdown the node or stop the kubelet on the node. Now watch as the
mysql-0 pod is rescheduled onto a different node.

Note that if you are using the CSI driver there is a CSI helper pod that can be
running as either a StatefulSet or as a Deployment. Given the nature of
StatefulSets make sure that the mysql-0 pod and the storageos-statefulset-0 pod
are not running on the same node or the volume will be unable to reattach.
StorageOS has fixed this by using a deployment for the CSI helper rather than a
StatefulSet. The deployment strategy is configurable using the
[StorageOSCluster deploymentStratergy
parameter](https://docs.storageos.com/docs/reference/cluster-operator/configuration).
```bash
kubectl get pods -l app=mysql -o wide
NAME      READY   STATUS    RESTARTS   AGE    IP           NODE                           NOMINATED NODE   READINESS GATES
client    1/1     Running   0          1m     10.244.2.4   ip-10-1-10-235.storageos.net   <none>           <none>
mysql-0   1/1     Running   0          1m     10.244.1.6   ip-10-1-10-118.storageos.net   <none>           <none>

kubectl get pods -n storageos -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP          NODE                           NOMINATED NODE   READINESS GATES
cli                         1/1     Running   0          50m   10.244.1.4  ip-10-1-10-118.storageos.net   <none>           <none>
storageos-daemonset-b9f8v   3/3     Running   0          57m   10.1.10.112 ip-10-1-10-112.storageos.net   <none>           <none>
storageos-daemonset-q64cm   3/3     Running   0          57m   10.1.10.235 ip-10-1-10-235.storageos.net   <none>           <none>
storageos-daemonset-t75m2   3/3     Running   0          57m   10.1.10.118 ip-10-1-10-118.storageos.net   <none>           <none>
storageos-statefulset-0     3/3     Running   0          57m   10.244.1.3  ip-10-1-10-118.storageos.net   <none>           <none>
```

Once the node is in a NotReady state you'll see that the mysql-0 pod has been
rescheduled on a different node. In this example you can see that the MySQL
client pod was scheduled on the same node as the mysql-0 pod and is still in
the Terminating state. This is because a pod cannot be terminated until the
kubelet comes back up and the pod is not rescheduled because a pod has no
controller.

```bash
kubectl get pods -o wide
NAME      READY   STATUS        RESTARTS   AGE   IP           NODE                           NOMINATED NODE   READINESS GATES
client    1/1     Terminating   0          1m    10.244.2.4   ip-10-1-10-235.storageos.net   <none>           <none>
mysql-0   1/1     Running       0          30s   10.244.1.6   ip-10-1-10-118.storageos.net   <none>           <none>
```

The pod can be force deleted and recreated so MySQL can be queried again.
```bash
kubectl delete pod client --force --grace-period 0
kubectl create -f ./k8s/examples/fencing/30-mysql-client-pod.yaml
```

Check that the client pod is running and query the shops database.
```bash
kubectl get pods 
NAME      READY   STATUS    RESTARTS   AGE
client    1/1     Running   0          44s
mysql-0   1/1     Running   0          1m

kubectl exec -it client -- mysql -h mysql-0.mysql -u root -e "use shop; select * from books;"
+---------------+-------+
| title         | price |
+---------------+-------+
| Gates of Fire | 13.99 |
+---------------+-------+
```
