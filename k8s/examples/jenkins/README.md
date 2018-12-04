# Jenkins on Kubernetes with StorageOS Persistent Storage

This example shows an example of how to deploy Jenkins on Kubernetes with a
StorageOS persistent volume being mounted on `/var/jenkins_home`. The files
create a stateful set that can be used *AFTER* a StorageOS cluster has been
created. For more information on how to install a StorageOS cluster please see
[the StorageOS
documentation](https://docs.storageos.com/docs/introduction/quickstart) for
more information.

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
port-foward'ing the Jenkins Kubernetes service to your localhost and accessing
the UI via your browser.

```bash
$ kubectl port-forward svc/jenkins 8080:8080
$ curl localhost:8080
```

If you inspect the service you'll see that port 50000 is also open. This has
been done deliberately to allow you to use the [Kubernetes Jenkins
plugin](https://github.com/jenkinsci/kubernetes-plugin).
