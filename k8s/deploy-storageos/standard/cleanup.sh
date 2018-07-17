#!/bin/bash

kubectl delete sc/fast
kubectl delete -n storageos all --all --now
kubectl delete -n storageos sa/storageos role/storageos rolebinding/storageos psp/storageos-psp role/storageos-psp-user rolebinding/storageos-psp-user --now
kubectl delete ns storageos --now
