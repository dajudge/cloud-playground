# About `cloud-playground`
The name is a real giveaway here: it's a playground for easily toying around with several cloud tools / technologies,
such as:

* Docker related:
  * docker
  * docker-compose
  * docker registry
* Kubernetes related:
  * minikube
  * kubectl
  * helm
  * nginx-ingress
* Messaging
  * Kafka
  * RabbitMQ

I mainly use this playground for trainings and other educational purposes.

*Note*: This playground has only been tested on Ubuntu 18.04!

# Getting started
*Note:* I assume you are running Ubuntu 18.04 and already have `git` installed.

## **Install docker**
You need docker on your computer in order to get started.

*Note*: This is a condensed form of [this piece of docker documentation](https://docs.docker.com/install/linux/docker-ce/ubuntu/).
```
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
## **Install kvm2**
You need kvm2 in order to use minikube.

*Note*: This is a consensed form of [this piece of minikube documentation](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver).
```
sudo apt-get update
sudo apt install libvirt-clients libvirt-daemon-system qemu-kvm
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
sudo systemctl status libvirtd.service
newgrp libvirt
```

## Configure docker for insecure registry
Make sure your `/etc/docker/daemon.json` file allows the following IP range for insecure
docker registries.
``` 
{
        "insecure-registries": ["192.168.0.0/16"]
}
```
*Note:* I always got IPs in this range for my minikube kvm2 VMs - yours might might be different!

And apply by restarting your docker daemon
```
user@host:~ sudo service docker restart
```

## Checkout repo & enter workbench
The playground is based on a docker image that contains all the tools required for execution of the 
demos. This docker image I call the "workbench". Everything you do with the cloud-playground you'll
do inside a workbench container.

*Important:* You're still working with your host system's docker daemon and kvm2 instance. Your
home directory will be mounted into the workbench container and you'll be working with your
normal user account inside the container. The container also shares the host system's network
stack. 

Checkout this repo:
```
user@host:~/devel$ git checkout https://github.com/dajudge/cloud-playground.git
```
Enter repo's directory:
```
user@host:~/devel$ cd cloud-playground
```
*Optional step:* Build workbench image. This is also automatically done by `workbench.sh`. Do
this if you want to know what's happening during the workbench image build.
```
user@host:~/devel/cloud-playground$ docker build .workbench/
...
Successfully built 1bab219e6cb4
```
Enter workbench:
```
user@host:~/devel/cloud-playground$ ./workbench.sh
You are now inside the cloud-playground workbench.
user@host:~/devel/cloud-playground$
```

# Things to try
Once you're inside the cloud-playground there are several things you can try out.
## Start a minikube
### Start minikube
Start `minikube` using kvm2 with the following specs (adjust according to your machine's specs):
* 24GB RAM
* 100GB HDD
```
user@host:~/devel/cloud-playground$ minikube start --vm-driver kvm2 --memory 24576 --disk-size 100g
* minikube v1.1.0 on linux (amd64)
* Creating kvm2 VM (CPUs=2, Memory=24576MB, Disk=100000MB) ...
* Configuring environment for Kubernetes v1.14.2 on Docker 18.09.6
* Pulling images ...
* Launching Kubernetes ... 
* Verifying: apiserver proxy etcd scheduler controller dns
* Done! kubectl is now configured to use "minikube"
```
Check status of your k8s cluster via `kubectl`:
```
user@host:~/devel/cloud-playground$ kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
minikube   Ready    master   2m47s   v1.14.2
```
### Enable ingress feature
Enable nginx-ingress feature via `minikube`:
```
user@host:~/devel/cloud-playground$ minikube addons enable ingress
* ingress was successfully enabled
```
Verify nginx-ingress is running:
```
user@host:~/devel/cloud-playground$ kubectl get pods -n kube-system
NAME                                        READY   STATUS    RESTARTS   AGE
...
nginx-ingress-controller-586cdc477c-x8cdp   0/1     Running   0          31s
...
```
## Init helm & docker registry
### Helm
Run helm installation via demo script:
```
user@host:~/devel/cloud-playground$ demo01-setup/01-helm.sh
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created
$HELM_HOME has been configured at /home/user/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
```
Check if helm installation was successful (can take a minute or two):
```
user@host:~/devel/cloud-playground$ helm version
Client: &version.Version{SemVer:"v2.14.0", GitCommit:"05811b84a3f93603dd6c2fcfe57944dfa7ab7fd0", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.0", GitCommit:"05811b84a3f93603dd6c2fcfe57944dfa7ab7fd0", GitTreeState:"clean"}
```
### docker registry
Run helm chart for docker registry and create ingress via demo script:
```
user@host:~/devel/cloud-playground$ demo01-setup/02-registry.sh
NAME:   registry
LAST DEPLOYED: Sat Jun  1 08:12:11 2019
NAMESPACE: registry
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                             DATA  AGE
registry-docker-registry-config  1     0s

==> v1/Pod(related)
NAME                                       READY  STATUS             RESTARTS  AGE
registry-docker-registry-7b7cd45d44-lqtsj  0/1    ContainerCreating  0         0s

==> v1/Secret
NAME                             TYPE    DATA  AGE
registry-docker-registry-secret  Opaque  1     0s

==> v1/Service
NAME                      TYPE       CLUSTER-IP   EXTERNAL-IP  PORT(S)   AGE
registry-docker-registry  ClusterIP  10.102.51.4  <none>       5000/TCP  0s

==> v1beta1/Deployment
NAME                      READY  UP-TO-DATE  AVAILABLE  AGE
registry-docker-registry  0/1    1           0          0s
...
```
Verify the registry is up and running:
```
user@host:~/devel/cloud-playground$ kubectl get pods -n registry
NAME                                        READY   STATUS    RESTARTS   AGE
registry-docker-registry-7b7cd45d44-lqtsj   1/1     Running   0          83s
```

## Try out Kafka
Kafka is a high-throughput messaging system implemented on top of the JVM.

### Deploy Kafka with helm
Make sure you have installed helm/tiller before trying to install Kafka with it:
```
user@host:~/devel/cloud-playground$ helm version
Client: &version.Version{SemVer:"v2.14.0", GitCommit:"05811b84a3f93603dd6c2fcfe57944dfa7ab7fd0", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.0", GitCommit:"05811b84a3f93603dd6c2fcfe57944dfa7ab7fd0", GitTreeState:"clean"}
```
Install Kafka using helm (via convenience script):
```
user@host:~/devel/cloud-playground$ demo02-kafka/01-kafka.sh
"confluentinc" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "confluentinc" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete.
NAME:   kafka
LAST DEPLOYED: Fri May 31 08:49:09 2019
NAMESPACE: kafka
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                                         DATA  AGE
kafka-cp-kafka-connect-jmx-configmap         1     0s
kafka-cp-kafka-jmx-configmap                 1     0s
kafka-cp-kafka-rest-jmx-configmap            1     0s
kafka-cp-ksql-server-jmx-configmap           1     0s
kafka-cp-ksql-server-ksql-queries-configmap  1     0s
kafka-cp-schema-registry-jmx-configmap       1     0s
kafka-cp-zookeeper-jmx-configmap             1     0s

==> v1/Pod(related)
NAME                                       READY  STATUS             RESTARTS  AGE
kafka-cp-kafka-0                           0/2    Pending            0         0s
kafka-cp-kafka-connect-7d6cbd4866-c2hb5    0/2    ContainerCreating  0         0s
kafka-cp-kafka-rest-6b4788f55f-xgpvb       0/2    ContainerCreating  0         0s
kafka-cp-ksql-server-9cb67d96d-8slqr       0/2    ContainerCreating  0         0s
kafka-cp-schema-registry-7b75bdd6b6-xkf9j  0/2    Pending            0         0s
kafka-cp-zookeeper-0                       0/2    Pending            0         0s

==> v1/Service
NAME                         TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)            AGE
kafka-cp-kafka               ClusterIP  10.110.168.102  <none>       9092/TCP           0s
kafka-cp-kafka-connect       ClusterIP  10.99.247.121   <none>       8083/TCP           0s
kafka-cp-kafka-headless      ClusterIP  None            <none>       9092/TCP           0s
kafka-cp-kafka-rest          ClusterIP  10.102.95.240   <none>       8082/TCP           0s
kafka-cp-ksql-server         ClusterIP  10.103.27.171   <none>       8088/TCP           0s
kafka-cp-schema-registry     ClusterIP  10.98.33.230    <none>       8081/TCP           0s
kafka-cp-zookeeper           ClusterIP  10.107.20.124   <none>       2181/TCP           0s
kafka-cp-zookeeper-headless  ClusterIP  None            <none>       2888/TCP,3888/TCP  0s

==> v1beta1/PodDisruptionBudget
NAME                    MIN AVAILABLE  MAX UNAVAILABLE  ALLOWED DISRUPTIONS  AGE
kafka-cp-zookeeper-pdb  N/A            1                0                    0s

==> v1beta1/StatefulSet
NAME                READY  AGE
kafka-cp-kafka      0/3    0s
kafka-cp-zookeeper  0/3    0s

==> v1beta2/Deployment
NAME                      READY  UP-TO-DATE  AVAILABLE  AGE
kafka-cp-kafka-connect    0/1    1           0          0s
kafka-cp-kafka-rest       0/1    1           0          0s
kafka-cp-ksql-server      0/1    1           0          0s
kafka-cp-schema-registry  0/1    1           0          0s
...
```
Wait for Kafka to be ready (can take a couple of minutes):
```
user@host:~/devel/cloud-playground$ kubectl get pods -n kafka
NAME                                        READY   STATUS    RESTARTS   AGE
kafka-cp-kafka-0                            2/2     Running   0          2m13s
kafka-cp-kafka-1                            2/2     Running   0          34s
kafka-cp-kafka-2                            2/2     Running   0          30s
kafka-cp-kafka-connect-7d6cbd4866-r64gz     2/2     Running   3          2m13s
kafka-cp-kafka-rest-6b4788f55f-68br4        2/2     Running   1          2m13s
kafka-cp-ksql-server-9cb67d96d-t74br        2/2     Running   2          2m13s
kafka-cp-schema-registry-7b75bdd6b6-xf26c   2/2     Running   2          2m13s
kafka-cp-zookeeper-0                        2/2     Running   0          2m13s
kafka-cp-zookeeper-1                        2/2     Running   0          27s
kafka-cp-zookeeper-2                        2/2     Running   0          20s
```
### Produce / consume messages
Start a consumer pod:
```
user@host:~/devel/cloud-playground$ demo02-kafka/02-consumer.sh 
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM ubuntu:bionic
 ---> 7698f282e524
Step 2/4 : RUN apt-get update &&     apt-get install -y python3 python3-pip &&     rm -rf /var/lib/apt/lists/* &&     pip3 install kafka-python
 ---> Using cache
 ---> 7c3cee8078c0
Step 3/4 : ADD consumer.py /
 ---> Using cache
 ---> 6119f15cb272
Step 4/4 : CMD ["python3", "/consumer.py"]
 ---> Using cache
 ---> 9ba689023f9b
Successfully built 9ba689023f9b
Successfully tagged registry.192.168.39.109.xip.io:80/demo02/consumer:1559399104
The push refers to repository [registry.192.168.39.109.xip.io:80/demo02/consumer]
1e41ab14b600: Layer already exists 
822e4c818914: Layer already exists 
8d267010480f: Layer already exists 
270f934787ed: Layer already exists 
02571d034293: Layer already exists 
1559399104: digest: sha256:d2a7f07126e81535b2fbc275456c7c2d89fa388ff2098037046a1af9de8f47fd size: 1363
pod/kafka-consumer created
```
Start a producer pod:
```
user@host:~/devel/cloud-playground$ demo02-kafka/03-producer.sh 
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM ubuntu:bionic
 ---> 7698f282e524
Step 2/4 : RUN apt-get update &&     apt-get install -y python3 python3-pip &&     rm -rf /var/lib/apt/lists/* &&     pip3 install kafka-python
 ---> Using cache
 ---> 7c3cee8078c0
Step 3/4 : ADD producer.py /
 ---> 5379470d1222
Step 4/4 : CMD ["python3", "/producer.py"]
 ---> Running in 53ea80bd2d77
Removing intermediate container 53ea80bd2d77
 ---> d5e3a67617b2
Successfully built d5e3a67617b2
Successfully tagged registry.192.168.39.109.xip.io:80/demo02/producer:1559399188
The push refers to repository [registry.192.168.39.109.xip.io:80/demo02/producer]
89f7d479d8b5: Pushed 
822e4c818914: Layer already exists 
8d267010480f: Layer already exists 
270f934787ed: Layer already exists 
02571d034293: Layer already exists 
1559399188: digest: sha256:ab8b725aaebeed3278ef064c56ba60854dcd70760f123d7b7424b926ae5a5870 size: 1363
pod/kafka-producer created
```
See messages coming in on the consumer side:
```
user@host:~/devel/cloud-playground$ kubectl logs -n kafka kafka-consumer
Starting kafka consumer: kafka-cp-kafka.kafka.svc:9092
Received {'number': 0}
Received {'number': 1}
Received {'number': 2}
Received {'number': 3}
Received {'number': 4}
Received {'number': 5}
Received {'number': 6}
Received {'number': 7}
Received {'number': 8}
Received {'number': 9}
```
Great success!
## Try out RabbitMQ
RabbitMQ is a rather classic open source message broker implemented in Erlang.
### Deploy RabbitMQ with helm
```
user@host:~/devel/cloud-playground$ demo03-rabbitmq/01-rabbitmq.sh
NAME:   rabbitmq
LAST DEPLOYED: Sat Jun  1 14:46:41 2019
NAMESPACE: rabbitmq
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME             DATA  AGE
rabbitmq-config  2     0s

==> v1/Pod(related)
NAME        READY  STATUS   RESTARTS  AGE
rabbitmq-0  0/1    Pending  0         0s

==> v1/Role
NAME                      AGE
rabbitmq-endpoint-reader  0s

==> v1/RoleBinding
NAME                      AGE
rabbitmq-endpoint-reader  0s

==> v1/Secret
NAME      TYPE    DATA  AGE
rabbitmq  Opaque  2     0s

==> v1/Service
NAME               TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)                                AGE
rabbitmq           ClusterIP  10.111.66.153  <none>       4369/TCP,5672/TCP,25672/TCP,15672/TCP  0s
rabbitmq-headless  ClusterIP  None           <none>       4369/TCP,5672/TCP,25672/TCP,15672/TCP  0s

==> v1/ServiceAccount
NAME      SECRETS  AGE
rabbitmq  1        0s

==> v1beta2/StatefulSet
NAME      READY  AGE
rabbitmq  0/1    0s
...
```
Check it's working:
```
user@host:~/devel/cloud-playground$ kubectl get pods -n rabbitmq
NAME         READY   STATUS    RESTARTS   AGE
rabbitmq-0   1/1     Running   0          16m
```
### Open Management UI
You can use your browser to access RabbitMQ's Management UI.

The default credentials are:
* user: 'user'
* password: 's3cr3t'
```
user@host:~/devel/cloud-playground$ echo "Point your browser to: http://$(kubectl get ing -n rabbitmq rabbitmq -o jsonpath="{.spec.rules[0].host}")"
Point your browser to: http://rabbitmq.192.168.39.62.xip.io
```
### Send messages via RabbitMQ
Start a publisher on queue 'playgroud':
```
user@host:~/devel/cloud-playground$ demo03-rabbitmq/03-producer.sh 
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM ubuntu:bionic
 ---> 7698f282e524
Step 2/4 : RUN apt-get update &&     apt-get install -y python3 python3-pip &&     rm -rf /var/lib/apt/lists/* &&     pip3 install pika
 ---> Using cache
 ---> 77e080ebbe53
Step 3/4 : ADD producer.py /
 ---> b067ba19851c
Step 4/4 : CMD ["python3", "/producer.py"]
 ---> Running in 99423383da28
Removing intermediate container 99423383da28
 ---> f9c14bdc1576
Successfully built f9c14bdc1576
Successfully tagged registry.192.168.39.62.xip.io:80/demo03/producer:1559407538
The push refers to repository [registry.192.168.39.62.xip.io:80/demo03/producer]
566f05c7b2b9: Pushed 
486e398b1558: Layer already exists 
8d267010480f: Layer already exists 
270f934787ed: Layer already exists 
02571d034293: Layer already exists 
1559407538: digest: sha256:0430e2dade03a943e3ab499f7abd1404d38b1bed0cb283c29accd9e11db15031 size: 1363
pod/rabbitmq-producer created
```
You should not be able to verify using the Management UI that messages are being sent to the
queue.