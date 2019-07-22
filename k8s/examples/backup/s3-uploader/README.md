# Upload files from application Pods to S3

In this example use case we provide a solution to export data from an
application Pod to a helper Pod that uploads the data to S3.

## Components

### Application StatefulSet

The StatefulSet with application  data is created with 2 StorageOS volumes. One
for the data and one for the backups directory. Many applications
allow backups to be exported remotely, but some only allow backups to the local
filesystem. In this example, the directory to store backups inside the
container is `/backups`.

The same StatefulSet runs a second sidecar container exposing a Rsync daemon.
The Rsync container shares the `/backup` location with the application (main)
container.

> To expose files without having a separate location for backups, while using
> the data path, the Kubernetes manifests can be changed in the Statefulset
> volumes section to share the `/data` volume.

### S3 Uploader

A Kubernetes Cron Job is created. That scheduler creates a Pod running two programs.
Firstly the Pod connects to the Rsync daemon running in the StatefulSet via a
Kubernetes Service and syncs the `/backup` directory. It then uploads the
content into an S3 bucket.

The connection to Rsync is established using a username and password injected to
the Worker via Kubernetes Secrets. Both the Rsync daemon and the client use the
same Secret.

A few parameters are passed to the Worker Pod using a ConfigMap. The configurable
information is the Rsync Service Name and the Credentials to access Rsync and
the S3 Bucket.

Finally, the Worker uses a Secret to download the AWS credentials. Set your own
parameters and credentials in the Kubernetes manifests.

To change the frequency of the Worker trigger, you can change the Kubernetes
manifest for the Cron Job. The current configuration runs a backup every hour.

> Make sure you set your AWS credentials in the Secret
> `k8s-manifests/05-aws-secret.yaml` and the S3 bucket name in the ConfigMap
> `k8s-manifests/90-uploader-config.yaml`.

