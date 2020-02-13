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

Configiguration available in `group_vars/all`.

## Run

```
ansible-playbook -i hosts.example site.yml
```

## Example etcdctl 

etcdctl is install under /usr/local/bin

```
ETCDCTL_API=3 ./etcdctl --endpoints=172.28.128.16:2379 member list
```

