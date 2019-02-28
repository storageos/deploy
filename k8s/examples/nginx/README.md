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

Connect to the nginx pod and write a file to /usr/share/nginx/html that Nginx
will serve.

```bash
$ kubectl exec nginx-0 -it -- bash
root@nginx-0:/# echo Hello world! > /usr/share/nginx/html/greetings.txt
```

Connect to the BusyBox pod and connect to the Nginx server through the
service.

```bash
$ kubectl exec -it busybox -- /bin/sh
/ # wget -q -O- nginx
<html>
<head><title>Index of /</title></head>
<body>
<h1>Index of /</h1><hr><pre><a href="../">../</a>
<a href="greetings.txt">greetings.txt</a>
27-Feb-2019 12:04                  13                                                                        
</pre><hr></body>
</html>
```

Display the contents of the greetings.txt file
```bash
/ # wget -q -O- nginx/greetings.txt
Hello world!
```
The output of the first command shows a directory index containing the
greetings.txt file and the second command displays the content of the file.
