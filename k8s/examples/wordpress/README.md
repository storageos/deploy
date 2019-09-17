# Wordpress with MySQL on Kubernetes with StorageOS Persisent Storage

This example shows how to deploy a WordPress site and a MySQL database, an NGINX Ingress Controller and an NFS Server. The files build two Stateful Sets that can be used after a StorageOS Cluster has been created. For
more information on how to install a StorageOS cluster please see
[the StorageOS documentation](https://docs.storageos.com/docs/introduction/quickstart)
for more information.

# Deploy

## Prerequisites

 1. Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) for your Provider.

 > Check the Ingress Controller service is deployed and the pods are running using the following commands.

 ```
$ kubectl get service
NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
kubernetes                                 ClusterIP      10.43.240.1     <none>          443/TCP                      57m
my-nginx-nginx-ingress-controller          LoadBalancer   10.43.244.81    35.195.97.236   80:30758/TCP,443:31772/TCP   35m
my-nginx-nginx-ingress-default-backend     ClusterIP      10.43.240.77    <none>          80/TCP                       35m

 ```

```
$ kubectl get pods

NAME                                                      READY   STATUS              RESTARTS   AGE
my-nginx-nginx-ingress-controller-7f96c4cb75-xmp8h        1/1     Running             0          39m
my-nginx-nginx-ingress-default-backend-5547cf6b98-cpkfb   1/1     Running             0          39m

```

2. Clone this repository.

```
git clone https://github.com/storageos/deploy.git storageos
```

## Deploy MySQL

Firstly you will need to create all the Kubernetes objects for MySQL Part of this example.

```
$ cd storageos
$ kubectl create -f ./k8s/examples/wordpress/mysql
```

Once this is done you can check that a mysql pod is running.
```
$ kubectl get pods -l app=wordpress,tier=mysql

NAME                READY   STATUS    RESTARTS   AGE
client              1/1     Running   0          4m
wordpress-mysql-0   1/1     Running   0          4m

```

Connect to the MySQL Client Pod and connect to the MySQL server through the service.

```
$ k exec -it client -- bash 
root@client:/# mysql -h wordpress-mysql-0.wordpress-mysql -uroot -p  
// enter your password. In this example is just the word password
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)
```

## Deploy WordPress

```
$ kubectl create -f ./k8s/examples/wordpress/wordpress
```

Once this is done, you can check that the wordpress pods are running.

```
$ kubectl get pods -l app=wordpress,tier=frontend

kubectl get pods -l app=wordpress,tier=frontend 

NAME          READY   STATUS    RESTARTS   AGE
wordpress-0   1/1     Running   0          23m
wordpress-1   1/1     Running   0          15m
wordpress-2   1/1     Running   0          3m19s

```

Now if you check all the services you have for this example. You will notice that the Wordpress Service is using NodePort.

```
$ kubectl get service

NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
kubernetes                                 ClusterIP      10.43.240.1     <none>          443/TCP                      89m
my-nginx-nginx-ingress-controller          LoadBalancer   10.43.244.81    35.195.97.236   80:30758/TCP,443:31772/TCP   67m
my-nginx-nginx-ingress-default-backend     ClusterIP      10.43.240.77    <none>          80/TCP                       67m
pvc-413f31e8-d92c-11e9-9880-42010a840116   ClusterIP      10.43.241.113   <none>          2049/TCP,80/TCP              63m
wordpress                                  NodePort       10.43.253.98    <none>          8080:31814/TCP               63m
wordpress-mysql                            ClusterIP      None            <none>          3306/TCP                     65m
```