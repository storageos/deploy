#!/bin/bash


cm=$(find -type f -name '*.fio' | sed "s/^\(.*\)/--from-file=\1 /" | tr -d '\n')

echo "Creating FIO profiles as ConfigMaps"
kubectl create configmap fio-profiles-local &> /dev/null
kubectl create configmap fio-profiles-local $cm -o yaml --dry-run | kubectl replace -f -


