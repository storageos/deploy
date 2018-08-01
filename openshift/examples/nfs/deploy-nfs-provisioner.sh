#!/bin/bash

oc adm policy add-scc-to-user privileged system:serviceaccount:storageos:nfs-provisioner

oc create -f ./manifests
