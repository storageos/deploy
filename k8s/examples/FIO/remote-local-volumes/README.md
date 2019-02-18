# Create jobs

The volumes in this tests will be created without node selectors or hints,
therefore some volumes may be local to the FIO Pod and some remote. To test
using local volumes, look at the suggested tests in `../local-volumes/`.

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


# Verify that the Pod is running
~$ kubectl get pod -owide
```

4. Get the FIO results

```bash
~$ kubectl logs $POD
```

## Generate tests

Initial test specs are already defined in the jobs and profiles directories.
However, those are supplied as examples. If you wish to test other setups, you
can generate the tests with the Job Generator.

### 4, 8, 16 and 32 volumes


The script `job-generator-per-volumecount.sh` takes by parameter the number of
concurrent volumes to be used in the test.

```bash
~$ ./job-generator-per-volumecount.sh 4
~$ ./job-generator-per-volumecount.sh 8
~$ ./job-generator-per-volumecount.sh 16
~$ ./job-generator-per-volumecount.sh 32
```

The Job Generator creates a Job in `./jobs/` for each execution and its
according FIO profile file `./profiles/`. You can change the size of the
volumes by editing the ./jobs file.

You can edit the FIO profile to supply your own FIO parameters and upload
the ConfigMap again by executing `./upload-fio-profiles.sh`.
