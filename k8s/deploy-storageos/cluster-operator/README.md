# Cluster Operator

The StorageOS cluster operator is the recommended installation procedure to
deploy a StorageOS cluster.

The StorageOS cluster operator is a [Kubernetes native
application](https://kubernetes.io/docs/concepts/extend-kubernetes/extend-cluster/)
developed to deploy and configure StorageOS clusters, and assist with
maintenance operations.

The operator acts as a Kubernetes controller that watches the `StorageOSCluster`
CR. Once the controller is ready, a StorageOS cluster definition can be
created. The operator will deploy a StorageOS cluster based on the
configuration specified in the cluster definition.

You can find the source code in the [cluster-operator
repository](https://github.com/storageos/cluster-operator).

In the `examples` directory you can find `CRs (Cluster Resource)` that
represent a StorageOS cluster. The cluster operator will deploy a StorageOS
cluster based on the specification of this CRD (Cluster Resource Definition).

> Before creating the CR you must create the `storageos-api` secret that
> defines user/password for the API.

## 1. Install

You can install the operator by executing `deploy-operator.sh` and the operator
will be deployed based on the manifests dir, or follow the official
[docs](https://docs.storageos.com/docs/platforms/kubernetes/install/) page.

## 2. Create Secret
Before deploying a StorageOS cluster, create a Secret to define the StorageOS
API Username and Password in base64 encoding.

```bash
kubectl create -f - <<END
apiVersion: v1
kind: Secret
metadata:
  name: "storageos-api"
  namespace: "default"
  labels:
    app: "storageos"
type: "kubernetes.io/storageos"
data:
  # echo -n '<secret>' | base64
  apiUsername: c3RvcmFnZW9z
  apiPassword: c3RvcmFnZW9z
END
```

## 3. Create a CR to deploy StorageOS

```bash
CR_DEFINITION= # Your CR file based on examples
kubectl create -f $CR_DEFINITION
```

# Examples

> You can checkout all the parameters configurable in the [StorageOSCluster
> Resource
> Configuration](https://github.com/storageos/cluster-operator#storageoscluster-resource-configuration) page.

Among plenty of different combinations of parameters to deploy a StorageOS cluster you can
find as CR files in the `examples` directory, here are a few details.

All examples must reference the `storageos-api` Secret.

```bash
spec:
  secretRefName: "storageos-api" # Reference from the Secret created in the previous step
  secretRefNamespace: "default"  # Namespace of the Secret
```

### External etcd 

```bash
spec:
  kvBackend:
    address: 'storageos-etcd-client.etcd:2379' # SVC that exposes ETCD
  # address: '10.42.15.23:2379,10.42.12.22:2379,10.42.13.16:2379' # You can specify individual IPs of the etcd servers
    backend: 'etcd'
```

### Select nodes where StorageOS will deploy

In this case we select nodes that are workers. To make sure that StorageOS doesn't start in Master nodes. 

You can see the labels in the nodes by `kubectl get node --show-labels`.

```bash
spec:
  nodeSelectorTerms:
    - matchExpressions:
      - key: "node-role.kubernetes.io/worker"
        operator: In
        values:
        - "true"

# OpenShift uses "node-role.kubernetes.io/compute=true"
# Rancher uses "node-role.kubernetes.io/worker=true"
# Kops uses "node-role.kubernetes.io/node="
```

> Different provisioners and Kubernetes distributions use node labels
> differently to specify master vs workers. Node Taints are not enough to
> make sure StorageOS doesn't start in a node. The
> [JOIN](https://docs.storageos.com/docs/prerequisites/clusterdiscovery)
> variable is defined by the operator by selecting all the nodes that match the
> `nodeSelectorTerms`.

### Enabled CSI

```bash
spec:
  csi:
    enable: true
  # enableProvisionCreds: false
  # enableControllerPublishCreds: false
  # enableNodePublishCreds: false
```

The Creds must be defined in the `storageos-api` Secret

```bash
apiVersion: v1
kind: Secret
metadata:
  name: "storageos-api"
  namespace: "default"
  labels:
    app: "storageos"
type: "kubernetes.io/storageos"
data:
  # echo -n '<secret>' | base64
  apiUsername: c3RvcmFnZW9z
  apiPassword: c3RvcmFnZW9z
  # Add base64 encoded creds below for CSI credentials.
  # csiProvisionUsername:
  # csiProvisionPassword:
  # csiControllerPublishUsername:
  # csiControllerPublishPassword:
  # csiNodePublishUsername:
  # csiNodePublishPassword:
```

### Shared Dir for Kubelet as a container

```bash
spec:
  sharedDir: '/var/lib/kubelet/plugins/kubernetes.io~storageos'
```

### Define Pod resources

```bash
spec:
  resources:
    requests:
      memory: "256Mi"
  #   cpu: "1"
  # limits:
  #   memory: "4Gi"
```

Limiting StorageOS can cause malfunction for Read/Write to StorageOS volumes,
hence it is recommended to not restrict tightly the Pod resources.

## Clean up

The `cleanup.sh` will delete the operator deployment and all its CRDs. When
that happens the StorageOS daemonset managed by the operator will be removed
too.
