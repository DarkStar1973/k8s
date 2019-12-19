# k8s test

## Description
This will deploy a k8s custer on 3 local vbox nodes. 
Works only on a ubuntu bionic hosts with at least 16Go


## How use it:

First, edit Vagrantfile:
* Change bridge network IP to be on the same network that your host
* Change host's network interface to match with your interface name

Launch setup.sh, it will:
* install needed packages on host
* create 3 VM named kmaster, knode1, knode2 base on Vagrantfile
* launch ssh-agent if needed and add private vms ssh keys

Install k8s with kubespray:
* cd to kubespray folder
* launch: 
