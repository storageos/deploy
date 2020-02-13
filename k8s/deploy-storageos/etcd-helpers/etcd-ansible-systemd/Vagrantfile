# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = 3

# Cluster
hostnames = nodes.times.collect { |n| "centos-#{n + 1}" }

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  (1..nodes).each do |n|
    config.vm.define "centos-#{n}" do |node|
      node.vm.hostname = hostnames[n-1]
      node.vm.network "private_network", type: "dhcp"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.cpus = 2
      end
    end
  end
end
