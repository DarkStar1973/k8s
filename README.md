# k8s test

## Description
This will deploy a k8s cluster on 3 local vbox nodes in ubuntu/bionic64


## How use it:

### setup.sh

setup.sh script will create local 3 virtualboxes for 3 kubernetes nodes (1 master et 2 minions).
If you don't want to use local VMs but other hosts go to the ansible part of this doc.
You must adapt setup.sh for you environement. Vms must be in your local private network and you must tell virtualbox which local interfaces to bridge.

Edit theses vars:

```bash
KMASTER_IP="192.168.1.200"
KNODE1_IP="192.168.1.210"
KNODE2_IP="192.168.1.211"
BRIDGE_INT="enp3s0"
```

IP must be free ip address inside your private network
BRIDGE_INT must be the host's interface name on private network

Run setup.sh, it will:
- add requires tools on local host
- create the 3 virtualboxes on local host
- create ansible inventory for theses VMs

### Ansible

Inventory file for ansible has been created with setup.sh.
If you want to use you own hosts, adapt the inventory like this:

ansible/inventory/inventory.ini

```yaml
[all]
HOSTNAME_MASTER ansible_host=IP_MASTER_HOST ansible_ssh_private_key_file=PRIVATE_KEY_MASTER
HOSTNAME_NODE1 ansible_host=IP_NODE1  ansible_ssh_private_key_file=PRIVATE_KEY_NODE1
HOSTNALE_NODE2 ansible_host=IP_NODE2  ansible_ssh_private_key_file=PRIVATE_KEY_NODE2

[kube-master]
kmaster

[kube-node]
knode1
knode2
```

HOSTNAME_XX are mandatory, IP_XXX and PRIVATE_KEY are not if hosts are registered into dns and ssh key managed.

Deploy with ansible to create k8s cluster with flannel and istio

```bash
cd ansible
ansible-playbook deploy.yml -b -u vagrant -i inventory/inventory.ini -v
```

If you use you own host, adapt the deployment user vagrant here, it must have sudo right. If you use root directly, remove the "-b" option.

After deployment finish, wait for cluster to be ready, istio take some time with virtualboxes (10mns).

Log in to the master and verify istio:

```bash
ssh -i .vagrant/machines/kmaster/virtualbox/private_key vagrant@192.168.1.200 
sudo su -
kubectl get pods -n istio-system`
```

All pods must be ready:

```
NAME                                      READY   STATUS    RESTARTS   AGE
grafana-6b65874977-qnh6p                  1/1     Running   0          9m24s
istio-citadel-86dcf4c6b-6sjmv             1/1     Running   0          9m28s
istio-egressgateway-68f754ccdd-jzlvv      1/1     Running   0          9m26s
istio-galley-5fc6d6c45b-5xzm9             1/1     Running   0          9m26s
istio-ingressgateway-6d759478d8-2b7f4     1/1     Running   0          9m26s
istio-pilot-5c4995d687-dl7xs              1/1     Running   0          9m25s
istio-policy-57b99968f-tswpx              1/1     Running   7          9m27s
istio-sidecar-injector-746f7c7bbb-chss5   1/1     Running   0          9m27s
istio-telemetry-854d8556d5-hwqbk          1/1     Running   6          9m26s
istio-tracing-c66d67cd9-rlvt9             1/1     Running   0          9m26s
kiali-8559969566-vsxrz                    1/1     Running   0          9m26s
prometheus-66c5887c86-lqxgr               1/1     Running   0          9m25s
```

On the master, you will find a deployment example (simple ngnix). We will create a service to access it.

```bash
kubectl label namespace default istio-injection=enabled # activate sidecar injection on default namespace
kubectl apply -f /opt/k8s/nginx-deployment.yml # deploy nginx
kubectl expose deployment nginx-deployment --type=NodePort --name=nginx-service
```

You can verify sidecar injection:

````bash
root@kmaster: # kubectl get pod
NAME                             READY   STATUS    RESTARTS   AGE
nginx-deployment-9f46bb5-7lx72   2/2     Running   0          8m8s
nginx-deployment-9f46bb5-jnm4n   2/2     Running   0          8m8s
nginx-deployment-9f46bb5-lgp94   2/2     Running   0          8m8s
nginx-deployment-9f46bb5-n76vq   2/2     Running   0          8m8s


root@kmaster: # kubectl describe pod nginx-deployment-9f46bb5-7lx72
Name:         nginx-deployment-9f46bb5-7lx72
Namespace:    default
Priority:     0
Node:         knode1/192.168.1.210
Start Time:   Fri, 20 Dec 2019 19:43:29 +0000
Labels:       app=nginx
              pod-template-hash=9f46bb5
              security.istio.io/tlsMode=istio
Annotations:  sidecar.istio.io/status:
                {"version":"8d80e9685defcc00b0d8c9274b60071ba8810537e0ed310ea96c1de0785272c7","initContainers":["istio-init"],"containers":["istio-proxy"]...

../..
```



