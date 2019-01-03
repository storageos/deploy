# File exfiltration on Kubernetes from StorageOS persistent volumes

This example is provided to give ideas of how to exfiltrate files that have
been written to a StorageOS persistent volume. This example uses nginx, rsync
and sftp sidecars in an application pod. This approach may be useful to create
out-of-cluster backups of data.

In this example the "application" container is the container "main", which has
rsync, nginx and sftp sidecar containers. The StorageOS volume that the
application is writing to will be mounted into the sidecar containers as well so
backup files etc. can be exfiltrated. 

The files create a stateful set that can be used *AFTER* a StorageOS cluster
has been created. For more information on how to install a StorageOS cluster
please see [the StorageOS documentation]
(https://docs.storageos.com/docs/introduction/quickstart).

## Deploy

In order to deploy the pod clone this repostiory and use kubectl to create the
Kubernetes objects.

> Before deploying the backup-example stateful set we highly recomend looking
> through the examples to understand how the different containers are
> configured 

```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos
$ kubectl create -f ./k8s/examples/backup-example
```
Check that a backup-example pod is running

```bash
$ kubectl get pods -w -l app=backup-example
   NAME        READY    STATUS    RESTARTS    AGE
   backup-example-0     1/1      Running    0          1m
```

## Exfiltrating files through Nginx

Connect to the Nginx container running inside the backup-example pod through
the service that's configured in 10-service.yaml. In this example we do this by
executing wget from inside a Busybox pod.

```bash
$ kubectl exec -it busybox -- /bin/sh
/ # /bin/busybox wget backup-example
Connecting to backup-example (100.64.159.6:80)
index.html           100% |********************************|   367  0:00:00 ETA
/ # cat index.html
<html>
<head><title>Index of /</title></head>
<body>
<h1>Index of /</h1><hr><pre><a href="../">../</a>
<a href="helloworld.txt">helloworld.txt</a>  06-Nov-2018 14:42      12
<a href="date.txt">test.txt</a>              06-Nov-2018 14:54      16
</pre><hr></body>
</html>
/ # /bin/busybox wget backup-example/date.txt
Connecting to backup-example (100.64.159.6:80)
date.txt             100% |********************************|    56  0:00:00 ETA
```

Depending on what files have been written to the StorageOS volume the output of
the index file will be different. In the example above two .txt files were
present on the volume.

## Exfiltrating files through Rsync

Connect to the Rsync daemon, that's running inside the backup-example pod,
through the service. In the example below we do this by conencting to an rsync
pod. A username and password that are set in the rsync-credentials secret. The
secret supplied in the example has the username and password set to username
and password.

```
$ keti rsync -- sh
/ # rsync --list-only rsync://username@backup-example/share/
Password:
drwxr-xr-x          4,096 2019/02/05 15:53:21 .
-rw-r--r--             56 2019/02/04 13:56:57 date.txt
drwx------         16,384 2019/02/04 09:56:03 lost+found
/ # rsync -chavzP rsync://username@backup-example/share/date.txt .
Password:
receiving incremental file list
date
             28 100%   27.34kB/s    0:00:00 (xfr#1, to-chk=0/1)

sent 43 bytes  received 131 bytes  348.00 bytes/sec
total size is 28  speedup is 0.16

```
In the example above the list of avaliable files was shown and a file called
date.txt was synchronized to the rsync container.

## Exfiltrating files through SFTP

Connect to the SFTP container running as part of the backup-example pod through
the backup-example service. In order to do this a SFTP user needs to be
configured. The details for the user are stored in the sftp-config secret (see
17-secret.yaml). The secret consists of base64 encoded
username:password:uid:guid and the user is chrooted inside their home directory
so the mount point for the StorageOS volume in the SFTP conatiner in
20-backup-pod.yaml needs to be configured.

```bash
$ kubectl exec -it sftp -- bash
root@sftp:/# sftp alex@backup-example
alex@backup-example's password:
sftp> ls
date.txt    lost+found  
sftp> get date.txt
Fetching /date.txt to date.txt
/date.txt                          100%   56    53.6KB/s   00:00    

```

### Using custom SSH Keys

The ConfigMap ssh-key-pub (see 15-configmap.yaml) needs to be populated with a
public key. The corresponding private key needs to be base64 encoded and put
into the ssh-key-private secret (see 17-secret.yaml). The user to connect as is
determined by the user that is configured in the sftp-config configMap. To
restrict logins to the SSH key edit the sftp-config secret so it contains no
password (user::uid:guid).

Connect to the sftp pod and connect through the service to the SFTP container
running inside the backup-example pod. 

```bash 
$ kubectl exec -it sftp -- bash
root@sftp:/# sftp -i /home/alex/.ssh/id_rsa alex@backup-example
sftp>
```
