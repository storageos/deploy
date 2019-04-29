
# Elasticsearch with StorageOS

Elasticsearch is a distributed, RESTful search and analytics engine, most popularly used to aggregate logs, but also to serve as search backend to a number of different applications.

This repository is part of our use-case documentation and provides example YAML manifests to help you get started on running [Elasticsearch with StorageOS](https://docs.storageos.com/docs/usecases/kubernetes/elasticsearch).

Please visit the official docs page and please do leave us feedback for improvement or simply open a PR.

## Note

This example deployment requires a certain amount of resources as it will be deploying

- 3x data nodes
- 3x coordinator nodes
- 3x master nodes

requiring a combined ~14GB of memory (minimum), however, more memory may be
used by the application/s.

# Pre-Requisites

ES requires you to set a higher than default max_map_count, you can do this two (and more) ways:

```bash
echo 262144 > /proc/sys/vm/max_map_count
```

or

```bash
sysctl -w vm.max_map_count=262144
```

this setting needs to be applied on _every_ node that will be running an ES pod, so effectively on every node in your cluster.

# Install

First clone this repo

```bash
git clone https://github.com/storageos/deploy.git storageos
```

Then apply the elasticsearch manifests

```bash
kubectl apply -f storageos/k8s/examples/elasticsearch/
```

# Connect

To connect to ES, simply use the following port-forward command

```bash
kubectl port-forward `kubectl get pods -l role=coordinator -o jsonpath='{ $.items[0].metadata.name }'` 9200
```

which will make ES available via [http://localhost:9200](http://localhost:9200)
