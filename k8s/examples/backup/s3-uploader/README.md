# Upload files from application Pods to S3

In this example use case we provide a solution to export data from an
application Pod to a helper worker that uploads the data to S3.

## Components

### Application StatefulSet

The StatefulSet with relevant data is created with 2 StorageOS volumes. One
for the data and one for the backups directory. Many applications
allow to export backups remotely, but many only allow backups to the local
filesystem. In this example, the directory to store backups inside the
container is `/backups`.

The same StatefulSet runs a second side car container exposing a rsync daemon.
The Rsync container shares the `/backup` location with the application (main)
container.

> If the user requires to be able to expose files without having a
> specific location for backups, but using the data path, the Kubernetes manifests
> can be changed in the Statefulset volumes section to share the `/data`
> volume.

### S3 Uploader

A Kubernetes Cron Job is created. The Job scheduled creates a Pod that runs two
programs. First, connects to the Rsync daemon running in the StatefulSet via a
Kubernetes Service. It syncs the `/backup` directory and uploads the content
into an S3 bucket.

The connection to Rsync is established using username and password injected to
the Job via Kubernetes Secrets. Both the Rsync daemon and the client use the
same Secret.

A few parameters are passed to the Job worker using a ConfigMap. The
information configurable is the Rsync Service Name, the Credentials to access
the Rsync and the S3 Bucket.

Finally, the Job uses a Secret to download the AWS credentials. Set your own
parameters and credentials in the Kubernetes manifests.

To change the frequency of the worker trigger, you can change the Kubernetes
manifest for the Cron Job. The current configuration runs a backup every hour.

> Make sure you set your AWS credentials in the Secret
> `k8s-manifests/05-aws-secret.yaml` and the S3 bucket name in the ConfigMap
> `k8s-manifests/90-uploader-config.yaml`.

