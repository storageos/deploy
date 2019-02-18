#!/bin/bash

AUX="$1"
NS="${AUX:-default}"

cm=$(find -type f -name '*.fio' | sed "s/^\(.*\)/--from-file=\1 /" | tr -d '\n')

echo "Creating FIO profiles as ConfigMaps"
kubectl -n $NS create configmap fio-profiles &> /dev/null
kubectl -n $NS create configmap fio-profiles $cm -o yaml --dry-run | kubectl -n $NS replace -f -
