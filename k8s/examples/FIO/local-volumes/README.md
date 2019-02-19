# Create jobs

The script `job-generator-per-volumecount.sh` takes an argument for the number
of concurrent volumes to be used in the test and an argument for the name of
the node where the volumes and pods will attempt to be allocated.

## Tests suggested

1. Get the node name where the volumes and the Pod should be collocated.

```bash
kubectl get node --show-labels
```

> The Node name and the label `kubernetes.io/hostname` have to match.

> The Node selected must have enough capacity to host all the volumes
> created for the test.

2. Generate tests (4, 8, 16 and 32 volumes)


```bash
~$ ./job-generator-per-volumecount.sh 4  $NODE_NAME1
~$ ./job-generator-per-volumecount.sh 8  $NODE_NAME2
~$ ./job-generator-per-volumecount.sh 16 $NODE_NAME3
~$ ./job-generator-per-volumecount.sh 32 $NODE_NAME4
```

The Job Generator creates a Job in `./jobs/` for each execution and its
according FIO profile file `./profiles/`. You can change the size of the
volumes by editing the ./jobs file.

3. Upload FIO profiles as ConfigMaps

```bash
~$ ./upload-fio-profiles.sh
```

The uploader creates a ConfigMap with all the FIO config files that will be
injected into the Job.

4. Run the tests

```bash
~$ kubectl create -f ./jobs/$JOB.yaml

```

5. Check the provisioning

```bash
~$ # Check that all the PVCs are provisioned 
~$ kubectl get pvc

# Use StorageOS CLI to verify where the volumes are collocated

# As a binary
~$ storageos volume ls 

# As a container
~$ kubectl -n storageos exec cli -- storageos volume ls


# Verify that the Pod is running in the same Node
~$ kubectl get pod -owide
```

6. Get the FIO results

```bash
~$ kubectl logs $POD
```
