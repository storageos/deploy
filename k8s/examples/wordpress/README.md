# Wordpress with MySQL on Kubernetes with StorageOS Persisent Storage

This example shows how to deploy a WordPress site and with a MySQL database, an NGINX Ingress Controller and an NFS Server. The files build two StatefulSets that can be used after a StorageOS Cluster has been created. For
more information on how to install a StorageOS cluster please see
[the StorageOS documentation](https://docs.storageos.com/docs/introduction/quickstart)
for more information.

# Deploy

## Prerequisites

 1. Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) for your Provider.

 > Check the Ingress Controller service is deployed and the pods are running
 > using the following commands.

 ```
$ kubectl get service
NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
kubernetes                                 ClusterIP      10.43.240.1     <none>          443/TCP                      5m
my-nginx-nginx-ingress-controller          LoadBalancer   10.43.244.81    35.195.97.236   80:30758/TCP,443:31772/TCP   5m
my-nginx-nginx-ingress-default-backend     ClusterIP      10.43.240.77    <none>          80/TCP                       5m

```
> Make a note of the `EXTERNAL-IP`, as this will be used to access the WordPress Site.

```
$ kubectl get pods

NAME                                                      READY   STATUS              RESTARTS   AGE
my-nginx-nginx-ingress-controller-7f96c4cb75-xmp8h        1/1     Running             0          3m
my-nginx-nginx-ingress-default-backend-5547cf6b98-cpkfb   1/1     Running             0          3m

```

2. Self-Signed Certificate for TLS

 > When creating the certificate you will be asked to provide the
 > Common Name (eg, your name or your server's hostname), in case of our example
 > it needs to be `test.example.com` . The host is specified in `25-ingress.yml`.
 ```
$ mkdir certs
$ cd certs
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./tls-key.key -out ./tls-cert.crt
$ kubectl create secret tls tls-certificate --key ./tls-key.key --cert ./tls-cert.crt
$ kubectl label secret tls-certificate app=wordpress
 ```

3. Clone this repository.

```
$ git clone https://github.com/storageos/deploy.git storageos
```

## Deploy MySQL

Firstly you will need to create all the Kubernetes objects for the MySQL Part of this example.

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
root@client:/# mysql -h wordpress-mysql -uroot -p
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

Create the require Kubernetes Objects for WordPress.

```
$ kubectl create -f ./k8s/examples/wordpress/wordpress
```

Once this is done, you can check that the wordpress pods are running.

```
$ kubectl get pods -l app=wordpress,tier=frontend

NAME          READY   STATUS    RESTARTS   AGE
wordpress-0   1/1     Running   0          5m
wordpress-1   1/1     Running   0          5m
wordpress-2   1/1     Running   0          5m

```

Now if you check all the services you have for this example. You will notice that the WordPress Service is using NodePort.
By default we are using NodePort, because it allows us to exposes the Service on each Node’s IP at a static port. And for this example we don't necessarily need to expose the Service externally using explixitly a cloud provider’s load balancer, using the LoadBalancer. AS we are going to use the NGINX Ingress to route external traffic to our backend service. However if you wish to change the service type, you can do that in `wordpress/10-service.yml`.

```
$ kubectl get service

NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
kubernetes                                 ClusterIP      10.43.240.1     <none>          443/TCP                      10m
my-nginx-nginx-ingress-controller          LoadBalancer   10.43.244.81    35.195.97.236   80:30758/TCP,443:31772/TCP   7m
my-nginx-nginx-ingress-default-backend     ClusterIP      10.43.240.77    <none>          80/TCP                       7m
pvc-413f31e8-d92c-11e9-9880-42010a840116   ClusterIP      10.43.241.113   <none>          2049/TCP,80/TCP              3m
wordpress                                  NodePort       10.43.253.98    <none>          8080:31814/TCP               3m
wordpress-mysql                            ClusterIP      None            <none>          3306/TCP                     5m
```

Check that you can access the WordPress Site using the external IP provided by the NGINX Ingress Controller.

```
curl -kv --resolve test.example.com:443:<nginx_ing_external_ip> https://test.example.com
curl -Lk --resolve test.example.com:443:<nginx_ing_external_ip> https://test.example.com/
```
> The `nginx_ing_external_ip`, will be the NGINX Ingress Controller external IP saved during [prerequisites](#prerequisites).