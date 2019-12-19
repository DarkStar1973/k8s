
$provision = <<-SCRIPT
sudo systemctl stop apt-daily.timer
sudo systemctl disable apt-daily.timer
sudo apt-get remove -qqy unattended-upgrades
sudo systemctl stop unattended-upgrades.service
sudo echo "192.168.1.200   kmaster" >> /etc/hosts
sudo echo "192.168.1.210    knode1" >> /etc/hosts
sudo echo "192.168.1.211    knode2" >> /etc/hosts
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "kmaster" do |kmaster|
    kmaster.vm.hostname = "kmaster"
    kmaster.vm.box = "ubuntu/bionic64"
    kmaster.vm.network :public_network, ip: "192.168.1.200", bridge: "enp3s0"
    kmaster.vm.synced_folder ".", "/vagrant", disabled: true
    kmaster.vm.provision "shell", inline: $provision
    kmaster.vm.provider "virtualbox" do |vmaster|
      vmaster.name = "vmaster"
      vmaster.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "knode1" do |knode1|
    knode1.vm.hostname = "knode1"
    knode1.vm.box = "ubuntu/bionic64"
    knode1.vm.network :public_network, ip: "192.168.1.210", bridge: "enp3s0"
    knode1.vm.synced_folder ".", "/vagrant", disabled: true
    knode1.vm.provision "shell", inline: $provision
    knode1.vm.provider "virtualbox" do |vnode1|
      vnode1.name = " vnode1"
      vnode1.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "knode2" do |knode2|
    knode2.vm.hostname = "knode2"
    knode2.vm.box = "ubuntu/bionic64"
    knode2.vm.network :public_network, ip: "192.168.1.211", bridge: "enp3s0"
    knode2.vm.network "public_network", bridge: "enp3s0"
    knode2.vm.synced_folder ".", "/vagrant", disabled: true
    knode2.vm.provision "shell", inline: $provision
    knode2.vm.provider "virtualbox" do |vnode2|
      vnode2.name = "vnode2"
      vnode2.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

end
