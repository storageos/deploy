#!/usr/bin/env bash

oc adm policy add-scc-to-user nonroot system:serviceaccount:monitoring:alertmanager-main
oc adm policy add-scc-to-user nonroot system:serviceaccount:monitoring:prometheus-k8s
oc adm policy add-scc-to-user hostaccess system:serviceaccount:monitoring:prometheus-k8s
oc adm policy add-scc-to-user privileged system:serviceaccount:monitoring:node-exporter
