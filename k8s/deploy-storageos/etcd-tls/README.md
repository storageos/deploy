# Install etcd with Cluster TLS

1. Run deploy-etcd-tls.sh to install the etcd operator and bootstrap an etcd
   cluster
   ```bash
   ./deploy-etcd-tls.sh
   ```
1. Check that the etcd pods are all in a running state
   ```bash
   kubectl get pods -w -n etcd
   ```
1. Run deploy-storageos-tls.sh to deploy the StorageOS cluster
   ```bash
   cd storageos-deployment
   ./deploy-storageos.sh
   ```

# Cleaning up

The cleanup.sh scripts will delete everything deployed by their respective
deploy scripts.
* storageos-deployment/cleanup-storageos.sh will delete all resources created by storageos-deployment/deploy-storageos.sh
* cleanup-etcd.sh will delete all resources created by deploy-etcd-tls.sh.

# More details

deploy-etcd-tls.sh - The script will generate certificates for use by Etcd
Operator when it bootstraps an etcd cluster inside Kubernetes. By default the
script will install an etcd cluster inside the `etcd` namespace. The
certificates that are generated can be altered by editing the certs/json files.
The host used in server.json and peer.json are determined by the value of
metadata.name of the EtcdCluster resource found:
./etcd-deployment/etcd-cluster-config.yaml

deploy-storageos-tls - The script will bootstrap a StorageOS cluster using the
etcd cluster deployed in step 1. StorageOS will communicate with etcd using
TLS.

* For more information on the etcd operator refer to https://github.com/coreos/etcd-operator.
* For more information on how the certificates are generated please see
https://coreos.com/os/docs/latest/generate-self-signed-certificates.html
* For more information on how StorageOS works with TLS please see https://docs.storageos.com/docs/operations/etcd-tls
