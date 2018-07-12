# Deploy StorageOS for OpenShift 3.7

Deploy a StorageOS container on all your cluster nodes and connects OpenShift to them.

OpenShift 3.9 and forward enable the MountPropagation feature gate. Because of that, this installation can't use DaemonSets to run StorageOS

To install StorageOS in OpenShift 3.9+ follow the [documentation](https://docs.storageos.com/docs/install/openshift/).


## Hosts
Set the `storageos` section in your hosts file as defined in `./hosts.example`. Mind that the playbook looks for
the variable `openshift_ip`. 

## Install
```
ansible-playbook -i hosts.example site.yaml
```

