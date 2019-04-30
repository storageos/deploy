# Setting up Prometheus to Monitor StorageOS

CoreOS have created a Kubernetes Operator for installing Prometheus. The
operator uses ServiceMonitor custom resources (CRs) to scrape IP addresses
defined in Kubernetes Endpoints. This article is intended to provide a quick
guide to monitoring the StorageOS metrics endpoint and can be used with our
example [Grafana dashboard](https://grafana.com/dashboards/10093).

## Install the Prometheus Operator

1. Clone the StorageOS deploy repository and move into the
   `prometheus-operator` directory
    ```bash
    git clone https://github.com/coreos/prometheus-operator.git prometheus-operator
    ```
1. Deploy the quick start `bundle.yaml`
    ```bash
    kubectl create -f prometheus-operator/bundle.yaml
    ```
1. Verify that the Prometheus operator is running.
   ```bash
   kubectl get pods -l apps.kubernetes.io/name=prometheus-operator
   ```

## Install Prometheus

Now that the Prometheus Operator is installed, a Prometheus CR can be created
which the Prometheus operator will act upon to configure a Prometheus StatefulSet

1. Clone the StorageOS deploy repo
   ```bash
   git clone https://github.com/storageos/deploy.git storageos
   cd storageos/k8s/examples/prometheus
   ```
1. If your cluster uses RBAC then create the necessary Cluster role and service
   account for Prometheus.
   ```bash
   kubectl create -f prometheus-rbac.yaml
   ```
1. Create a Prometheus CR that defines a Prometheus StatefulSet.
   ```bash
   kubectl create -f prometheus-cr.yaml
   ```
1. Create a ServiceMonitor CR that directs Prometheus to scrape the Endpoints
   defined in the `storageos` Endpoints resource. Prometheus will scrape the
   `/metrics` URL of the Endpoints and collect the metrics.
   ```
   kubectl create -f storageos-serviceMonitor.yaml
   ```
1. In order to view the Prometheus UI in the browser port forward the local
   port to the Prometheus pod port.
   ```bash
   kubectl port-forward prometheus-prometheus-storageos-0 9090
   ```
   The Prometheus UI can now be seen in the browser at localhost:9090
1. Now that the Prometheus UI is available StorageOS metrics can be queried
   from the Graph page. A complete list of StorageOS metrics can be found
   [here](/docs/reference/prometheus)

## Installing Grafana

Grafana is a popular solution for visualising metrics. At the time of writing
(30/04/2019) there is no Grafana operator so instead a helm installation is
used. If a helm installation will not work then the helm generated manifests
can be used.

1. Install Grafana
   ```bash
   helm install stable/grafana
   ```
1. Grafana can query the Prometheus pod for metrics, through a Service. The
   Prometheus operator automatically creates a service in any namespace that a
   Prometheus resource is created in. Setup a Grafana data source that points at
   the Prometheus service that was created. The URL to use will depend on the
   namespace that Grafana is installed into.

   If the Grafana pod runs in the same namespace as the
   Prometheus pod then the URL is: `http://prometheus-operated:9090` otherwise it's
   `http://prometheus-operated.$NAMESPACE.svc:9090`

   When creating the data source make sure to set the scrape interval.
1. Once the Prometheus data source has been created have a look at the [example
   StorageOS dashboard](https://grafana.com/dashboards/10093) for ideas about
   how to monitor your cluster.

CoreOS have created a Kubernetes Operator for installing Prometheus. The
operator uses ServiceMonitor custom resources (CRs) to scrape IP addresses
defined in Kubernetes Endpoints. This article is intended to provide a quick
guide to monitoring the StorageOS metrics endpoint and can be used with our
example [Grafana dashboard](https://grafana.com/dashboards/10093).

## Install the Prometheus Operator

1. Clone the StorageOS deploy repository and move into the
   `prometheus-operator` directory
    ```bash
    git clone https://github.com/coreos/prometheus-operator.git prometheus-operator
    ```
1. Deploy the quick start `bundle.yaml`
    ```bash
    kubectl create -f prometheus-operator/bundle.yaml
    ```
1. Verify that the Prometheus operator is running.
   ```bash
   kubectl get pods -l app=prometheus-operator
   ```
## Install Prometheus

Now that the Prometheus Operator is installed, a Prometheus CR can be created
which the Prometheus operator will act upon to configure a Prometheus StatefulSet
1. If your cluster uses RBAC then create the necessary Cluster role and service
   account for Prometheus.
   ```bash
   kubectl create -f prometheus-rbac.yaml
   ```
1. Create a Prometheus CR that defines a Prometheus StatefulSet. 
   ```bash
   kubectl create -f prometheus-cr.yaml
   ```
1. Create a ServiceMonitor CR that directs Prometheus to scrape the Endpoints
   defined in the StorageOS Endpoints resource.
   ```
   kubectl create -f storageos-serviceMonitor.yaml
   ```
1. In order to view the Prometheus UI in the browser port forward the local
   port to the Prometheus pod port.
   ```bash
   kubectl port-forward prometheus-prometheus-storageos-0 9090
   ```
   The Prometheus UI can now be seen in the browser at localhost:9090
1. Now that the Prometheus UI is available StorageOS metrics can be queried
   from the Graph page. A complete list of StorageOS metrics can be found
   [here](/docs/reference/prometheus)

## Installing Grafana

Grafana is a popular solution for visualising metrics. At the time of writing
(30/04/2019) there was no Grafana operator so instead a helm installation is
used. If a helm installation will not work then the helm generated manifests
can be used.

1. Install Grafana
   ```bash
   helm install stable/grafana
   ```
1. Grafana can query the Prometheus pod for metrics, through a Service. The
   Prometheus operator automatically creates a service in any namespace that a
   Prometheus resource is created in. Setup a Grafana data source that points at
   the Prometheus service that was created. The URL to use will depend on the
   namespace that Grafana is installed into.

   If the Grafana pod runs in the same namespace as the
   Prometheus pod then the URL is: `http://prometheus-operated:9090` otherwise it's
   `http://prometheus-operated.$NAMESPACE.svc:9090`

   When creating the data source make sure to set the scrape interval.
1. Once the Prometheus data source has been created have a look at the [example
   StorageOS dashboard](https://grafana.com/dashboards/10093) for ideas about
   how to monitor your cluster.
