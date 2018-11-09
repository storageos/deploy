# Nginx on Kubernetes with StorageOS persistent Storage

This example shows an example of how to deploy Nginx on Kubernetes, in order to
exfiltrate files that have been written to a StorageOS persistent volume. The
files create a stateful set that can be used *AFTER* a StorageOS cluster has
been created. For more information on how to install a StorageOS cluster please see
[the StorageOS documentation]
(https://docs.storageos.com/docs/introduction/quickstart).

## Deploy

In order to deploy Nginx you just need to clone this repostiory and use
kubectl to create the Kubernetes objects. 

```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos
$ kubectl create -f ./k8s/examples/nginx
```
Once this is done you can check that a nginx pod is running

```bash
$ kubectl get pods -w -l app=nginx
   NAME        READY    STATUS    RESTARTS    AGE
   nginx-0     1/1      Running    0          1m
```

Connect to the BusyBox pod and connect to the Nginx server through the
service.

```bash
$ kubectl exec -it busybox -- /bin/sh
/ # /bin/busybox wget nginx
Connecting to nginx (100.65.25.183:80)
index.html           100% |**********************************************************************|   367  0:00:00 ETA
/ # cat index.html
<html>
<head><title>Index of /</title></head>
<body>
<h1>Index of /</h1><hr><pre><a href="../">../</a>
<a href="helloworld.txt">helloworld.txt</a>                                     06-Nov-2018 14:42                  12
<a href="test.txt">test.txt</a>                                           06-Nov-2018 14:54                  16
</pre><hr></body>
</html>

```

Depending on what files you have written to the StorageOS volume the output of
the index file will be different. In the example above two txt files were
present on the volume.
