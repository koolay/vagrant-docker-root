# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant_rancheros_guest_plugin.rb'

Vagrant.configure(2) do |config|
  config.vm.define "docker-root"

  #config.vm.box = "docker-root"
  config.vm.box = "ailispaw/docker-root"

  config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.synced_folder "./docker/data", "/opt/data"
  config.vm.synced_folder "./docker/app", "/opt/app"
  config.vm.synced_folder "./docker/etc", "/opt/etc"

  # for NFS synced folder
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ["nolock", "vers=3", "udp"]

  # for RSync synced folder
  # config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__args: ["--verbose", "--archive", "--delete", "--copy-links"]

  if Vagrant.has_plugin?("vagrant-triggers") then
    config.trigger.after [:up, :resume] do
      info "Adjusting datetime after suspend and resume."
      run_remote "sudo sntp -4sSc pool.ntp.org; date"
    end
  end

  # Adjusting datetime before provisioning.
  config.vm.provision :shell, run: "always" do |sh|
    sh.inline = "sntp -4sSc pool.ntp.org; date"
  end

  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 9876, host: 9876
  config.vm.network :forwarded_port, guest: 6379, host: 6379
  config.vm.network :forwarded_port, guest: 3306, host: 3306 
  config.vm.network :forwarded_port, guest: 11211, host: 11211 
end
