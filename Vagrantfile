# -*- mode: ruby -*-
# vi: set ft=ruby :

var_box = "generic/rocky8"

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end
  
  config.vm.define "console" do |nodes|
    nodes.vm.box = var_box
    nodes.vm.hostname= "console"
    nodes.vm.network "public_network", ip: "192.168.0.210", bridge: "enx24f5a28b44a6"
    nodes.vm.provision :hosts, :sync_hosts => true
    nodes.vm.provider "virtualbox" do |v|
      v.memory = "512"
      v.cpus = "1"
      v.name = "console"
    end
    
    nodes.vm.synced_folder ".", "/vagrant"
    nodes.vm.synced_folder "./keys", "/vagrant_keys"
    nodes.vm.provision "shell", inline: "cp /vagrant/.vagrant/machines/console/virtualbox/private_key /vagrant_keys/key"
    nodes.vm.provision "shell", inline: <<-SHELL
      sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
      echo -e "root\nroot" | passwd root
      sudo systemctl restart sshd

      sudo sh /vagrant_keys/config.sh
      sudo sh /vagrant_keys/generate_public_key.sh
      sudo sh /vagrant_keys/copy_keys.sh
    SHELL
  end

  # Postgres nodes
  (1..2).each do |i|
    config.vm.define "pg#{i}" do |nodes|
      nodes.vm.box = var_box
      nodes.vm.hostname = "pg#{i}"
      nodes.vm.network "public_network", ip: "192.168.0.21#{i}", bridge: "enx24f5a28b44a6"
      nodes.vm.provision :hosts, :sync_hosts => true
#      nodes.vm.network "forwarded_port", guest: 5444, host: "544#{i}"
      
      nodes.vm.provider "virtualbox" do |v|
        v.memory = "1024"
        v.cpus = "2"
        v.name = "pg#{i}"
      end
      
      nodes.vm.synced_folder ".", "/vagrant"
      nodes.vm.synced_folder "./keys", "/vagrant_keys"
      nodes.vm.provision "shell", inline: <<-SHELL
        echo -e "root\nroot" | passwd root

        sudo systemctl restart sshd
        sh /vagrant_keys/config.sh

        sudo sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/copy_keys.sh

        systemctl stop firewalld
      SHELL
    end
   end

  # Barman
  (3..3).each do |i|
    config.vm.define "barman" do |nodes|
      nodes.vm.box = var_box
      nodes.vm.hostname = "barman"
      nodes.vm.network "public_network", ip: "192.168.0.21#{i}", bridge: "enx24f5a28b44a6"
      nodes.vm.provider "virtualbox" do |v|
        v.memory = "512"
        v.cpus = "1"
        v.name = "barman"
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

  # PEM
  (4..4).each do |i|
    config.vm.define "pemserver" do |nodes|
      nodes.vm.box = var_box
      nodes.vm.hostname = "pemserver"
      nodes.vm.network "public_network", ip: "192.168.0.21#{i}", bridge: "enx24f5a28b44a6"
      nodes.vm.provider "virtualbox" do |v|
        v.memory = "2048"
        v.cpus = "2"
        v.name = "pemserver"
      end
      
      nodes.vm.synced_folder ".", "/vagrant"
      nodes.vm.synced_folder "./keys", "/vagrant_keys"

      nodes.vm.provision "shell", inline: <<-SHELL
        sudo systemctl restart sshd
        echo -e "root\nroot" | passwd root

        sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/copy_keys.sh
        
        systemctl stop firewalld
      SHELL
    end
  end
end
