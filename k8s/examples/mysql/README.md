# MySQL Server on Kubernetes with StorageOS persistent Storage

This example shows an example of how to deploy MySQL Server on Kubernetes with
MySQL data being written to a StorageOS persistent volume. The files create a
stateful set that can be used *AFTER* a StorageOS cluster has been created. For
more information on how to install a StorageOS cluster please see
[the StorageOS documentation](https://docs.storageos.com/docs/introduction/quickstart)
for more information.

## Deploy

In order to deploy MySQL you just need to clone this repostiory and use
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
   mysql-0     1/1      Running    0          1m
```

Connect to the MySQL client pod and connect to the MySQL server through the
service.

```bash
$ kubectl exec -it mysql-0 -- /opt/mysql-tools/bin/sqlcmd -S mysql-0.mysql -U SA -P 'Password15'
1> USE master;
2> GO
Changed database context to 'master'.
1> SELECT name, database_id, create_date FROM sys.databases ;
2> GO
name                        database_id create_date            
--------------------------- ----------- -----------------------
master                                1 2003-04-08 09:13:36.390
tempdb                                2 2018-11-02 16:30:37.907
model                                 3 2003-04-08 09:13:36.390
msdb                                  4 2018-10-19 01:18:57.300

(4 rows affected)
```
