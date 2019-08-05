# Deploy StorageOS for OpenShift 3.7

> This playbook is not actively maintained.

Deploy a StorageOS container on all your cluster nodes and connects OpenShift to them.

OpenShift 3.9 and forward enable the MountPropagation feature gate. The current installation of the playbook is for OpenShift 3.7. Because of that, this installation can't use DaemonSets to run StorageOS

To install StorageOS in OpenShift 3.9+ follow the [documentation](https://docs.storageos.com/docs/install/openshift/).


## Hosts
Set the `storageos` section in your hosts file as defined in `./hosts.example`. Mind that the playbook looks for
the variable `openshift_ip`. 

## Install
```
ansible-playbook -i hosts.example site.yaml
```

## OpenShift interface

The `openshift_interface` role in `site.yaml` is set to run in the group masters. However, it should
be run in one node as it creates an storageclass and secret using the `oc` cli tool. Executing more
than once will only result in the cli notifing that the resource already exists. In case of
multimaster configuration, change that role to run in one node only. Otherwise, you can run that task in your own
client, where oc as system:admin is available. 
