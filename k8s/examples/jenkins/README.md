# Jenkins on Kubernetes with StorageOS Persistent Storage

This example shows how to deploy Jenkins on Kubernetes with a StorageOS
persistent volume being mounted on `/var/jenkins_home`. The files create a
stateful set that can be used *AFTER* a StorageOS cluster has been created. For
more information on how to install a StorageOS cluster please see [the
StorageOS
documentation](https://docs.storageos.com/docs/introduction/quickstart) for
more information.

Deploying Jenkins using StorageOS offers multiple benefits. Firstly Jenkins can
spin up multiple build pods at once to allow concurrent builds of different
projects. Secondly Jenkins configuration is on a PersistentVolume so even if
the Jenkins pod is rescheduled the configuration will persist. Using StorageOS
[ volume replicas ]( https://docs.storageos.com/docs/concepts/replication ) allows
for failure of nodes holding the PersistentVolume without interrupting Jenkins.
Lastly by enabling [ StorageOS
fencing ]( https://docs.storageos.com/docs/concepts/fencing ) Jenkins time to
recover, in case of node failures, is greatly reduced.

## Deploy

In order to deploy Jenkins you just need to clone this repository and use
kubectl to create the Kubernetes objects.

```bash
$ git clone https://github.com/storageos/deploy.git storageos
$ cd storageos
$ kubectl create -f ./k8s/examples/jenkins
```
Once this is done you can check that a Jenkins pod is running

```bash
$ kubectl get pods -w -l app=jenkins
   NAME        READY    STATUS    RESTARTS    AGE
   jenkins-0   1/1      Running    0          1m
```

Connect to the Jenkins UI through the Jenkins service. You can do this by
port forwarding the Jenkins Kubernetes service to your localhost and accessing
the UI via your browser. Alternatively if you have network access to your
Kubernetes nodes then you can create a NodePort service and access Jenkins like
that. A NodePort service has been left in 10-service.yaml commented out.

Alternatively to port-forward the Jenkins service to your localhost using
kubectl:
`kubectl port-foward svc/jenkins 8080`

To login to the Jenkins UI use the credentials specified in `07-config.yaml`,
unless these have been changed from the defaults the username/password is
admin/password.

If you inspect the service you'll see that port 50000 is also open. This has
been done deliberately to allow the [Kubernetes Jenkins
plugin](https://github.com/jenkinsci/kubernetes-plugin) to create build agent
pods.

Once you are logged into the UI you can create a job that will be farmed out to
a Kubernetes plugin build agent. Go to the Jenkins settings and click
`Configure System`, scroll to down to the `Cloud` section. In this section
access to your Kubernetes cluster has been configured.

> N.B. At the time of writing the jenkins/jnlp-slave Docker image did not
> contain a fix for
> [JENKINS-59000](https://issues.jenkins-ci.org/browse/JENKINS-59000) so the
> Kubernetes service has a port appended as a workaround. This port is set in
> the jenkins configMap in 07-config.yaml.

Click New Item, enter a name for the project and select Freestyle project. Next
add an `Execute shell` build step. As a proof of concept you can use the bash
below to have the pod execute a sleep.

```bash
#!/bin/bash
sleep 1000
```
Save the project and select Schedule a build of your project. You can watch for
the appearance of a build pod using `kubectl get pods -l jenkins=agent -w`.
Once the pod is created you should see the Build Executor status in the Jenkins
UI display the pod.

To see multiple projects being built at once create another project and try
scheduling a build of both projects at the same time.

## Attribution

The yaml manifests for this example were adapted from the (Jenkins helm
chart)[https://github.com/helm/charts/tree/master/stable/jenkins].
