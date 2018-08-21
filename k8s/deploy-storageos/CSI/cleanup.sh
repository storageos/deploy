#!/bin/bash

kubectl delete sc/fast
kubectl delete -n storageos all --all --now
kubectl delete -n storageos sa/storageos role/storageos rolebinding/storageos --now
kubectl delete -f ./manifests
kubectl delete ns storageos --now
