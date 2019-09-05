# MySQL on Kubernetes with StorageOS persistent Storage

This example shows an example of how to deploy MySQL Server on Kubernetes with
MySQL data being written to a StorageOS persistent volume. The files create a
stateful set that can be used *AFTER* a StorageOS cluster has been created. For
more information on how to install a StorageOS cluster please see
[the StorageOS documentation](https://docs.storageos.com/docs/introduction/quickstart)
for more information.

## Deploy

In order to deploy MySQL you just need to clone this repository and use
kubectl to create the Kubernetes objects. 

```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos
$ kubectl create -f ./k8s/examples/mysql
```
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
