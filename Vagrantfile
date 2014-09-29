VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.6.3"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "boot2docker"
  config.vm.box = "yungsang/boot2docker"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/vagrant"

  # Uncomment below to use more than one instance at once
  # config.vm.network :forwarded_port, guest: 2375, host: 2375, auto_correct: true

  # Fix busybox/udhcpc issue
  config.vm.provision :shell do |s|
    s.inline = <<-EOT
      if ! grep -qs ^nameserver /etc/resolv.conf; then
        sudo /sbin/udhcpc
      fi
      cat /etc/resolv.conf
    EOT
  end

  # Adjust datetime after suspend and resume
  config.vm.provision :shell do |s|
    s.inline = <<-EOT
      sudo /usr/local/bin/ntpclient -s -h pool.ntp.org
      date
    EOT
  end

  config.vm.provision "file", source: "autorun.sh", destination: "/home/docker/autorun.sh"

  # Ensure that SSH'ing into the Vagrant box launches the dev environment
  config.vm.provision :shell do |s|
    s.inline = <<-EOT
      chmod u+x /home/docker/autorun.sh
      cp /usr/local/bin/docker /vagrant/app/bin/docker

      if ! grep -sqF "autorun.sh" /home/docker/.ashrc; then
        {
          echo
          echo "exec /home/docker/autorun.sh"
        } >> /home/docker/.ashrc
      fi
    EOT
  end

  # Build the docker image containing the development environment
  config.vm.provision :docker do |d|
    d.build_image "/vagrant/app", args: "-t develop"
  end

  config.vbguest.auto_update = false
end
