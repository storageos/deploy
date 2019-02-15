# Create jobs

The volumes in this tests will scatter across nodes, therefore some volumes
might be local to the FIO Pod and some remote. To test using local volumes,
check the suggested tests in `../local-volumes/`.

## Tests suggested

> If you want to generate your tests, skip to the section "Generate tests".

> You can tweak the FIO profiles in `./profiles/` to fulfill your needs.

1. Upload FIO profiles as ConfigMaps

```bash
~$ ./upload-fio-profiles.sh
```

The uploader creates a ConfigMap with all the FIO config files that will be
injected into the Job.

2. Run the tests

```bash
~$ kubectl create -f ./jobs/$JOB.yaml

```

3. Check the provisioning

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

4. Get the FIO results

```bash
~$ kubectl logs $POD
```

## Generate tests

Initial test specs are defined already in the jobs and profiles directory.
However, those are examples. In case of wanting other setups, you can generate
the tests with the Job Generator.

### 4, 8, 16 and 32GB volumes


The script `job-generator-per-volumecount.sh` takes by parameter the number of
concurrent volumes to be used in the test.

```bash
~$ ./job-generator-per-volumecount.sh 4
~$ ./job-generator-per-volumecount.sh 8
~$ ./job-generator-per-volumecount.sh 16
~$ ./job-generator-per-volumecount.sh 32
```

The Job Generator creates a Job in `./jobs/` for each execution and its
according FIO profile file `./profiles/`.

You can edit the FIO profile according to tests you want to execute and upload
the ConfigMap again executing `./upload-fio-profiles.sh`
