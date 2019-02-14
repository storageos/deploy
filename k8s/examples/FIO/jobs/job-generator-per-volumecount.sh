#!/bin/bash

if [ -z "$1" ]; then
    echo "Number of volumes not defined."
    exit 1
fi

num_vols="$1"
pvc_prefix="$RANDOM"
profile="profile-${num_vols}vol.fio"
manifest="./fio-${num_vols}vol.yaml"

for v in $(seq 0 $((--num_vols))); do
    cat <<END >> $manifest
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-${pvc_prefix}-$v
  namespace: default
  annotations:
    volume.beta.kubernetes.io/storage-class: fast
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
END

done


cat <<END >> $manifest
apiVersion: batch/v1
kind: Job
metadata:
  name: fio-${num_vols}vol
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: fio
        image: senax/docker-fio:latest
        command:
          - "fio"
          - "/tmp/$profile"
        volumeMounts:
          - name: fio-conf
            mountPath: /tmp/
END

for v in $(seq 0 $((--num_vols))); do
    cat <<END >> $manifest
          - name: vol$v
            mountPath: /mnt/pvc$v
END

done

cat <<"END" >> $manifest
        resources:
          requests:
            cpu: 500m
      volumes:
      - name: fio-conf
        configMap:
          name: fio-profiles
END


for v in $(seq 0 $((--num_vols))); do
    cat <<END >> $manifest
      - name: vol$v
        persistentVolumeClaim:
          claimName: pvc-${pvc_prefix}-$v
END

done


fio_files="/mnt/pvc0/fio.dat"
for v in $(seq 1 $((--num_vols))); do
    fio_files="$fio_files:/mnt/pvc$v/fio.dat"
done

cat <<END >> ../profiles/$profile
[global]
size=1GB
runtime=20
time_based=1
ioengine=libaio
direct=1
random_generator=tausworthe
random_distribution=random
rw=randrw
rwmixread=60
rwmixwrite=40
percentage_random=85
bs=4k
iodepth=128

[${num_vols}vols]
filename=$fio_files
END
