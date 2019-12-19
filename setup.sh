#!/bin/bash


## Vars
CWD=`pwd`
KMASTER_IP="192.168.1.200"
KNODE1_IP="192.168.1.210"
KNODE2_IP="192.168.1.211"
BRIDGE_INT="enp3s0"

echo "Generate Vagrantfile"

cat > Vagrantfile << EOF

\$provision = <<-SCRIPT
sudo systemctl stop apt-daily.timer
sudo systemctl disable apt-daily.timer
sudo apt-get remove -qqy unattended-upgrades
sudo systemctl stop unattended-upgrades.service
sudo echo "${KMASTER_IP}   kmaster" >> /etc/hosts
sudo echo "${KNODE1_IP}    knode1" >> /etc/hosts
sudo echo "${KNODE2_IP}    knode2" >> /etc/hosts
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "kmaster" do |kmaster|
    kmaster.vm.hostname = "kmaster"
    kmaster.vm.box = "ubuntu/bionic64"
    kmaster.vm.network :public_network, ip: "${KMASTER_IP}", bridge: "${BRIDGE_INT}"
    kmaster.vm.synced_folder ".", "/vagrant", disabled: true
    kmaster.vm.provision "shell", inline: \$provision
    kmaster.vm.provider "virtualbox" do |vmaster|
      vmaster.name = "vmaster"
      vmaster.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "knode1" do |knode1|
    knode1.vm.hostname = "knode1"
    knode1.vm.box = "ubuntu/bionic64"
    knode1.vm.network :public_network, ip: "${KNODE1_IP}", bridge: "${BRIDGE_INT}"
    knode1.vm.synced_folder ".", "/vagrant", disabled: true
    knode1.vm.provision "shell", inline: \$provision
    knode1.vm.provider "virtualbox" do |vnode1|
      vnode1.name = " vnode1"
      vnode1.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "knode2" do |knode2|
    knode2.vm.hostname = "knode2"
    knode2.vm.box = "ubuntu/bionic64"
    knode2.vm.network :public_network, ip: "${KNODE2_IP}", bridge: "${BRIDGE_INT}"
    knode2.vm.network "public_network", bridge: "enp3s0"
    knode2.vm.synced_folder ".", "/vagrant", disabled: true
    knode2.vm.provision "shell", inline: \$provision
    knode2.vm.provider "virtualbox" do |vnode2|
      vnode2.name = "vnode2"
      vnode2.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

end
EOF


echo "Setting up control machine"
echo "Adding ansible ppa"

add-apt-repository -y ppa:ansible/ansible
apt update -qqy

echo "installaing needed packages"
apt install -qqy vagrant virtualbox ansible python-netaddr python-pbr python-avc python-jmespath python-ruamel.yaml

echo "Starting VMs"
vagrant up


echo "Generate ansible inventory file"

cat > ansible/inventory/inventory.ini << EOF
[all]
kmaster ansible_host=${KMASTER_IP} ansible_ssh_private_key_file=${CWD}/.vagrant/machines/kmaster/virtualbox/private_key
knode1 ansible_host=${KNODE1_IP}  ansible_ssh_private_key_file=${CWD}/.vagrant/machines/knode1/virtualbox/private_key
knode2 ansible_host=${KNODE2_IP}  ansible_ssh_private_key_file=${CWD}/.vagrant/machines/knode2/virtualbox/private_key

[kube-master]
kmaster

[kube-node]
knode1
knode2

EOF
echo "Setup completed, you can go into ansible folder and deploy cluster with:"
echo ""
echo "ansible-playbook deploy.yml -b -u vagrant -i inventory/inventory.ini"
echo ""
echo "Once the deployment is complete, ssh to the master node and verify Kubernetes cluster: "
echo ""
echo "ssh vagrant@${KMASTER_IP} -i {CWD}/.vagrant/machines/kmaster/virtualbox/private_key "
echo "sudo kubectl get nodes"
