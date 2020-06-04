# Provision etcd3 cluster with Ansible

## Playbook

Install and run etcd3

## Inventory example

```
cat <<END > hosts.example
[nodes]
centos-1 ip=172.28.128.17
centos-2 ip=172.28.128.18
centos-3 ip=172.28.128.19
END
```

## Configuration

Configuration available in `group_vars/all`.

Role files are set with the parameter `remote_user: root`. Change the user to
match your setup. Note that they use the option `become`.

## Run

```
ansible-playbook -i hosts.example site.yml
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
ansible-playbook -i hosts.example restore.yaml
```

# Uninstall etcd3

This will delete the etcd data completely. That data will be unrecoverable.
It is recommended to make a backup before executing the uninstall.

```
ansible-playbook -i hosts.example uninstall.yaml --tags unrecoverable
```

> Note that without the "unrecoverable" tag, the playbook will do
> nothing. That is for the users safety.
