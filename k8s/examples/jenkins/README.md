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
the UI via your browser. To login to the Jenkins UI use the credentials
specified in `07-config.yaml`.

```bash
$ kubectl port-forward svc/jenkins 8080:8080
$ curl localhost:8080
```

If you inspect the service you'll see that port 50000 is also open. This has
been done deliberately to allow the [Kubernetes Jenkins
plugin](https://github.com/jenkinsci/kubernetes-plugin) to create build slave
pods.


Once you are logged into the UI you can create a job that will be farmed out to
a Kubernetes plugin build slave. Go to the Jenkins settings and click
`Configure System`, scroll to down to the `Cloud` section. In this section
access to your Kubernetes cluster has been configured. 

> N.B. At the time of writing the jenkins/jnlp-slave Docker image did not
> contain a fix for
> [JENKINS-59000](https://issues.jenkins-ci.org/browse/JENKINS-59000) so the
> Kubernetes service has a port appended as a workaround. This port is set in
> the jenkins configMap in 07-config.yaml.

Copy the Labels name from the Kubernetes Pod Template and click New Item. Enter
a name for the project and select Freestyle project. Select the `Restrict where
this project can be run` option and paste the Kubernetes Pod Template name into
the field. This will cause Jenkins to create a build pod when the build is run.
Next add an `Execute shell` build step. As a proof of concept you can use the
bash below to have the pod execute a sleep.

```bash
#!/bin/bash
sleep 10000
```

Save the project and select Schedule a build of your project. You can watch for
the appearance of a build pod using `kubectl get pods -l jenkins=slave -w`.
Once the pod is created you should see the Build Executor status in the Jenkins
UI display the pod.
