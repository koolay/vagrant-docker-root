# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant_rancheros_guest_plugin.rb'

Vagrant.configure(2) do |config|
  config.vm.define "docker-root"

  config.vm.box = "docker-root"

  config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.synced_folder ".", "/opt/vagrant/"

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
end
