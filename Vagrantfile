# -*- mode: ruby -*-
# vi: set ft=ruby :

var_box = "generic/rocky8"

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end
  
  config.vm.define "node0" do |nodes|
    nodes.vm.box = var_box
    nodes.vm.hostname= "node0"
    #MacOS workaround for VirtualBox 7
    nodes.vm.network "private_network", ip: "192.168.1.10", name: "HostOnly", virtualbox__intnet: true
    nodes.vm.provision :hosts, :sync_hosts => true
    nodes.vm.provider "virtualbox" do |v|
      v.memory = "512"
      v.cpus = "1"
      v.name = "vm_node0"
      #v.customize ["modifyvm", :id, "--groups", "/bdr/node0"]
    end
    
    nodes.vm.synced_folder ".", "/vagrant"
    nodes.vm.synced_folder "./keys", "/vagrant_keys"
    nodes.vm.provision "shell", inline: "cp /vagrant/.vagrant/machines/node0/virtualbox/private_key /vagrant_keys/key"
    nodes.vm.provision "shell", inline: <<-SHELL
      sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
      echo -e "root\nroot" | passwd root
      sudo systemctl restart sshd

      sudo sh /vagrant_keys/config.sh
      sudo sh /vagrant_keys/generate_public_key.sh
      sudo sh /vagrant_keys/copy_keys.sh
#      sudo sh /vagrant_keys/hostnames.sh
    SHELL
  end

  # BDR Nodes
  (1..5).each do |i|
    config.vm.define "node#{i}" do |nodes|
      nodes.vm.box = var_box
      nodes.vm.hostname = "node#{i}"
      nodes.vm.network "private_network", ip: "192.168.1.1#{i}", name: "HostOnly", virtualbox__intnet: true
      nodes.vm.provision :hosts, :sync_hosts => true
      nodes.vm.network "forwarded_port", guest: 5444, host: "544#{i}"
      nodes.vm.network "forwarded_port", guest: 6432, host: "643#{i}"
      nodes.vm.network "forwarded_port", guest: 8443, host: "54#{i}"
      nodes.vm.network "forwarded_port", guest: 8080, host: "8#{i}"
      
      nodes.vm.provider "virtualbox" do |v|
        v.memory = "1024"
        v.cpus = "2"
        v.name = "vm_node#{i}"
      end
      
      nodes.vm.synced_folder ".", "/vagrant"
      nodes.vm.synced_folder "./keys", "/vagrant_keys"
      nodes.vm.provision "shell", inline: <<-SHELL
        echo -e "root\nroot" | passwd root

        sudo systemctl restart sshd
        sh /vagrant_keys/config.sh

        sudo sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/copy_keys.sh
#        sudo sh /vagrant_keys/hostnames.sh

        systemctl stop firewalld
      SHELL
    end
   end

  # Barman
  (6..6).each do |i|
    config.vm.define "node#{i}" do |nodes|
      nodes.vm.box = var_box
      nodes.vm.hostname = "node#{i}"
      nodes.vm.network "private_network", ip: "192.168.1.1#{i}", name: "HostOnly", virtualbox__intnet: true
      nodes.vm.provider "virtualbox" do |v|
        v.memory = "512"
        v.cpus = "1"
        v.name = "vm_node#{i}"
      end
      
      nodes.vm.synced_folder ".", "/vagrant"
      nodes.vm.synced_folder "./keys", "/vagrant_keys"

      nodes.vm.provision "shell", inline: <<-SHELL
        sudo systemctl restart sshd
        echo -e "root\nroot" | passwd root

        sh /vagrant_keys/config.sh

        sudo sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/copy_keys.sh
        sudo sh /vagrant_keys/hostnames.sh
        
        systemctl stop firewalld
      SHELL
    end
   end
end
