# Backing up files from StorageOS volumes

In this example use case we provide three different strategies for accessing
files that have been written to a StorageOS  persistent volume.

In the following examples the "application" container is the container `main`,
which has a rsync, Nginx or sftp sidecar container. The StorageOS volume that
the application is writing to will be mounted into the sidecar container so
files written by the application are available for export. Files can be
exported using Nginx as a web file server, transferred using rsync or accessed
via SFTP.

The files create a stateful set that can be used *AFTER* a StorageOS cluster
has been created. [See our guide on how to install StorageOS on Kubernetes for more
information]({% link _docs/platforms/kubernetes/install/index.md %})


## Clone Repository

In order to deploy the examples, clone this repository and use kubectl to create the
Kubernetes objects.
```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos
```
> Before deploying the backup-example stateful set we recommend looking
> through the examples to understand how the different containers are
> configured

## Exfiltrating files through HTTP

1. Deploy the Nginx example
```bash
$ kubectl create -f nginx/
service/backup-example created
configmap/nginx-config created
statefulset.apps/backup-example created
pod/busybox created
```
1. Check that a backup-example pod is running
```bash
$ kubectl get pods -w -l app=backup-example-nginx
   NAME        READY    STATUS    RESTARTS    AGE
   backup-example-0     1/1      Running    0          1m
```

1. Exec into the `main` container and write some data to a file
```bash
$ kubectl exec -it backup-example-nginx-0 -c main bash
root@backup-example-0:/# echo $(date) > /data/date.txt
```
1. Check that the service exists
```bash
$ kubectl get svc backup-example-nginx
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backup-example-nginx   ClusterIP   100.65.18.199   <none>        80/TCP    46s
```

1. Use wget to access the files served by Nginx. Nginx is sharing files from
   the same volume that the `main` application container is writing to. The
   connection to the Nginx container is made via the backup-example service.
```bash
$ kubectl exec -it busybox -- /bin/wget -q -O- http://backup-example-nginx
    <html>
    <head><title>Index of /</title></head>
    <body>
    <h1>Index of /</h1><hr><pre><a href="../">../</a>
    <a href="lost%2Bfound/">lost+found/</a>
    12-Feb-2019 12:32                   -
    <a href="date.txt">date.txt</a>
    12-Feb-2019 12:49                  29
    </pre><hr></body>
    </html>
$ kubectl exec -it busybox -- /bin/wget -q -O- http://backup-example-nginx/date.txt
Tue Feb 12 12:49:15 UTC 2019
```

Depending on what files have been written to the StorageOS volume the output of
the index file will be different. In the example the date.txt file we created
in Step 2 is present on the volume.

## Exfiltrating files through Rsync

1. Deploy the rsync example
```bash
$ kubectl create -f rsync/
service/backup-example created
configmap/rsync-config created
secret/rsync-credentials created
statefulset.apps/backup-example created
pod/rsync created
```
1. Check that a backup-example pod is running
```bash
$ kubectl get pods -w -l app=backup-example-rsync
   NAME        READY    STATUS    RESTARTS    AGE
   backup-example-0     1/1      Running    0          1m
```

1. Exec into the `main` container and write some data to a file
```bash
$ kubectl exec -it backup-example-rsync-0 -c main bash
root@backup-example-0:/# echo $(date) > /data/date.txt
```
1. Check that the service exists
```bash
$ kubectl get svc backup-example-rsync
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backup-example-nginx   ClusterIP   100.65.18.199   <none>        80/TCP    46s
```

1. Use rsync to access the files shared by the rsync daemon. rsync is sharing
   files from the same volume that the `main` container is writing to. A
   username and password that are set in the rsync-credentials secret. The
   secret supplied in the example has the username and password set to username
   and password.
```
$ kubectl exec -it rsync sh
/ # rsync --list-only rsync://username@backup-example-rsync/share
Password:
drwxr-xr-x          4,096 2019/02/12 12:49:15 .
-rw-r--r--             29 2019/02/12 12:49:15 date.txt
drwx------         16,384 2019/02/12 12:32:40 lost+found
/ # rsync -chavzP rsync://username@backup-example-rsync/share/date.txt .
Password:
receiving incremental file list
date.txt
             29 100%   28.32kB/s    0:00:00 (xfr#1, to-chk=0/1)

             sent 43 bytes  received 135 bytes  50.86 bytes/sec
             total size is 29  speedup is 0.16
/ # cat date.txt
Tue Feb 12 12:49:15 UTC 2019
```
In the example above the list of available files was shown and a file called
date.txt was synchronized to the rsync container.

## Exfiltrating files through SFTP

1. Deploy the sftp example
```bash
$ kubectl create -f sftp/
```
1. Exec into the `main` container and write some data to a file
```bash
$ kubectl exec -it backup-example-sftp-0 -c main bash
root@backup-example-0:/# echo $(date) > /data/date.txt
```
1. Check that the service exists
```bash
$ kubectl get svc backup-example-sftp
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backup-example-sftp   ClusterIP   100.70.50.56    <none>        22/TCP    46s
```

1. Use SFTP to access the files shared by the SFTP container. If you have made
   no changes to the sftp-config secret the password is password.
```bash
$ kubectl exec -it sftp -- bash
root@sftp:/# sftp alex@backup-example-sftp
alex@backup-example-sftp's password:
Connected to backup-example-sftp.
sftp> ls
date.txt    lost+found
sftp> get date.txt
Fetching /date.txt to date.txt
/date.txt
100%   29    15.9KB/s   00:00
sftp> bye
root@sftp:/# cat date.txt
Tue Feb 12 17:51:32 UTC 2019
```
In order to do this a SFTP user needs to be configured. The details for the
user are stored in the sftp-config secret (see `sftp/17-secret.yaml`). The secret
consists of base64 encoded username:password:uid:guid and the user is chroot'ed
inside their home directory so the mount point for the StorageOS volume in the
SFTP container in `sftp/20-backup-pod.yaml` needs to be configured.

### Using custom SSH Keys

The ConfigMap ssh-key-pub (see `sftp/15-configmap.yaml`) needs to be populated with a
public key. The corresponding private key needs to be base64 encoded and put
into the ssh-key-private secret (see `sftp/17-secret.yaml`). The user to connect as is
determined by the user that is configured in the sftp-config configMap. To
restrict logins to the SSH key edit the sftp-config secret so it contains no
password (user::uid:guid).

1. Connect to the sftp pod and connect through the service to the SFTP container
running inside the backup-example pod. 
```bash 
$ kubectl exec -it sftp -- bash
root@sftp:/# sftp -i /home/alex/.ssh/id_rsa alex@backup-example-sftp
Connected to backup-example-sftp.
sftp> ls
date.txt    lost+found
```

