# Deploy StorageOS SystemD service

StorageOS can run as a docker container managed by SystemD.

## Hosts
Set the `storageos` section in your hosts file as defined in the `./hosts`. Mind that the playbook looks for
the variable `ansible_host` and the ip or the dns name of each host.

## Install
```
ansible-playbook -i hosts site.yaml
```

