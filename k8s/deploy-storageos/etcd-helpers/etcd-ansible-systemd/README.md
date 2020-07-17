# Provision etcd3 cluster with Ansible

## Playbook

Install and run etcd3

## Inventory example

```
cat <<END > hosts
[nodes]
centos-1 ip=172.28.128.17 ip="10.64.10.228"  fqdn="ip-10-64-10-228.eu-west-2.compute.internal"
centos-2 ip=172.28.128.18 ip="10.64.14.233"  fqdn="ip-10-64-14-233.eu-west-2.compute.internal"
centos-3 ip=172.28.128.19 ip="10.64.12.111"  fqdn="ip-10-64-12-111.eu-west-2.compute.internal"
END
```

## Configuration

Configuration available in `group_vars/all`.

Role files are set with the parameter `remote_user: root`. Change the user to
match your setup. Note that they use the option `become`.

### FQDN vs IPs
The playbook allows you to decide how to advertise the urls for etcd. Whether
is using fqdn or ip. That plays an important role when using TLS.

### TLS
The playbook allows you to enable TLS with client authentication and generates
the certificates for you. You can edit the cfssl configuration by amending the
json files in  `roles/tls_cert/templates/`

WARNING: The default CA for TLS is statically made as an example. IT SHOULD NOT
BE USED FOR PRODUCTION! You need to create your own CA either with your own
tools or using the script below.

To create your own CA, run `ansible-playbook create_ca.yaml`

NOTE: The script uses docker locally, make sure it is installed and properly configured.

The CA files will be created in `./roles/tls_cert/files`

## Run

```
ansible-playbook -i hosts install.yaml
```

## Example etcdctl

etcdctl is install under /usr/local/bin

```
ETCDCTL_API=3 ./etcdctl --endpoints=172.28.128.16:2379 member list
```

# Restore from a snapshot

Assuming the snapshot file exists, the playbook will run a restore of etcd. Set
the snapshot location by setting the variable `backup_file` in the
group_vars/all configuration.

```
ansible-playbook -i hosts restore.yaml
```

# Uninstall etcd3

This will delete the etcd data completely. That data will be unrecoverable.
It is recommended to make a backup before executing the uninstall.

```
ansible-playbook -i hosts uninstall.yaml --tags unrecoverable
```

> Note that without the "unrecoverable" tag, the playbook will do
> nothing. That is for the users safety.
