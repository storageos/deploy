# Reference external Etcd

Kubernetes allows the use of [external
Services](https://kubernetes.io/docs/concepts/services-networking/service/#externalname)
to create a DNS entry resolving to the fixed ip address of services hosted
outside the Kubernetes cluster.

## Etcd external service

1. Create the NameSpace

```
kubectl create namespace etcd
```

1. Create the Endpoint referencing the ip addresses of your cluster

> Change the ip list for your own addresses

```
apiVersion: v1
kind: Endpoints
metadata:
  name: storageos-etcd
  namespace: etcd
  labels:
    app: etcd
    cluster: storageos
subsets:
- addresses:
  - ip: 10.1.10.216
  - ip: 10.1.10.217
  - ip: 10.1.10.218
  ports:
  - name: client
    port: 2379
    protocol: TCP
```

1. Create the Service that will match the Endpoint above

```
apiVersion: v1
kind: Service
metadata:
  name: storageos-etcd
  namespace: etcd
  labels:
    app: etcd
    cluster: storageos
spec:
  clusterIP: None
  ports:
  - name: client
    port: 2379
    targetPort: 2379
  selector: null
```

You can now access the etcd cluster using Kubernetes Service names.
