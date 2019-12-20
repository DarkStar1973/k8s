# k8s test

## Description
This will deploy a k8s custer on 3 local vbox nodes in ubuntu/bionic64


## How use it:

### setup.sh

setup.sh script will create local 3 virtualboxes, that will be kubernetes nodes (1 master et 2 minions).
If you don't want to use local VMs but use real host on your network, go to the ansible part of this doc.
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

