# Elasticsearch with StorageOS

Elasticsearch is a distributed, RESTful search and analytics engine, most
popularly used to aggregate logs, but also to serve as search backend to a
number of different applications.

This repository is part of our use-case documentation and provides example YAML
manifests to help you get started on running [Elasticsearch with
StorageOS](https://docs.storageos.com/docs/usecases/kubernetes/elasticsearch).

Please visit the official docs page and please do leave us feedback for
improvement or simply open a PR.

## Note

This example deployment requires a certain amount of resources as it will be
deploying

- 3x data nodes
- 3x coordinator nodes
- 3x master nodes

requiring a combined ~14GB of memory (minimum), however, more memory may be
used by the application/s.

> You can change the memory application settings in the env variables passed to
> the ES container in `10-es-data.yaml`, `20-es-coordinator.yaml` and
> `30-es-master.yaml`.

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
kubectl port-forward svc/elasticsearch 9200
```

which will make ES available via [http://localhost:9200](http://localhost:9200)

# Note max_map_count

ES requires to set a higher than default max_map_count in the system running
the application. Because of that, the ES bootstrap initially applies that
parameter change. That requires an init container to run as privileged in your
system. In case you rather not set a privileged container for that purpose, you
can remove the `initContainers` section of `10-es-data.yaml`,
`20-es-coordinator.yaml` and `30-es-master.yaml`. Additionally you have to set
the max_map_count for each machine that will run any of the ES Pods by:

```bash
echo 262144 > /proc/sys/vm/max_map_count
```

or

```bash
sysctl -w vm.max_map_count=262144
```

> This setting needs to be applied on _every_ node that will be running an ES
> Pod if your remove the initContainer, so effectively on every node in your
> cluster.
