#!/bin/bash

oc delete sc/fast
oc delete -n storageos all --all --now
oc delete -n storageos sa/storageos role/storageos rolebinding/storageos --now
oc delete -f ./manifests/
oc delete ns storageos --now
