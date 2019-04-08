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
1. Move into the ./storageos-deployment/ folder to deploy the StorageOS cluster
   ```bash
   cd storageos-deployment
   cat ./README.md
   ```

# Cleaning up

The cleanup.sh scripts will delete everything deployed by their respective
deploy scripts.
* cleanup-etcd.sh will delete all resources created by deploy-etcd-tls.sh.
* See ./storageos-deployment/README.md for instructions on cleaning up a
  StorageOS operator deployed cluster
* ./storageos-deployment/storageos-manual-install/cleanup-storageos.sh will
  delete all manually created resources

# More details

deploy-etcd-tls.sh - The script will generate certificates for use by Etcd
Operator when it bootstraps an etcd cluster inside Kubernetes. By default the
script will install an etcd cluster inside the `etcd` namespace. The
certificates that are generated can be altered by editing the certs/json files.
The host used in server.json and peer.json are determined by the value of
metadata.name of the EtcdCluster resource found:
./etcd-deployment/etcd-cluster-config.yaml

* For more information on the etcd operator refer to https://github.com/coreos/etcd-operator.
* For more information on how the certificates are generated please see
https://coreos.com/os/docs/latest/generate-self-signed-certificates.html
* For more information on how StorageOS works with TLS please see https://docs.storageos.com/docs/operations/etcd-tls
