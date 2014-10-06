VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.6.3"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "boot2docker"
  config.vm.box = "yungsang/boot2docker"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
  end

  # Uncomment below to use more than one instance at once
  # config.vm.network :forwarded_port, guest: 2375, host: 2375, auto_correct: true

  # Fix busybox/udhcpc issue
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
      if ! grep -qs ^nameserver /etc/resolv.conf; then
        sudo /sbin/udhcpc
      fi
      cat /etc/resolv.conf
    EOT
  end

  # Adjust datetime after suspend and resume
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
      sudo /usr/local/bin/ntpclient -s -h pool.ntp.org
      date
    EOT
  end

  config.vm.provision "file", source: "autorun.sh", destination: "/home/docker/autorun.sh", run: "always"

  # Ensure that SSH'ing into the Vagrant box launches the dev environment
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
      chmod u+x /home/docker/autorun.sh || exit $?

      if ! grep -sqF "autorun.sh" /home/docker/.ashrc; then
        {
          echo
          echo "exec /home/docker/autorun.sh"
        } >> /home/docker/.ashrc
      fi
    EOT
  end

  # Ensure that the docker binary is available to the dev environment Dockerfile
  config.vm.provision "shell", inline: 'cp /usr/local/bin/docker /vagrant/develop/bin/docker'

  # Ensure that the /vagrant/.ssh directory (if present) is copied and that all
  # of the permissions are appropriately set.
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
      mkdir -p  /home/docker/.ssh-inner || exit $?
      chmod 700 /home/docker/.ssh-inner || exit $?

      if [ -d /vagrant/.ssh ]; then
        cp -f /vagrant/.ssh/* /home/docker/.ssh-inner/ || exit $?
        (
          cd /home/docker/.ssh-inner || exit $?
          {
            chmod -f 600 *
            chmod -f 644 *.pub
            chmod -f 640 authorized_keys
            chmod -f 644 known_hosts
          } &> /dev/null
        )
      fi

      # Should be owned by the inner docker user (root)
      chown -R root:root /home/docker/.ssh-inner
    EOT
  end

  # Ensure that the "repos" directory exists
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
      mkdir -p /mnt/sda/repos || exit $?
      chown root:docker /mnt/sda/repos || exit $?
      chmod 775 /mnt/sda/repos || exit $?
    EOT
  end

  # Build the docker image containing the development environment
  config.vm.provision :docker do |d|
    d.build_image "/vagrant/develop", args: "-t develop"
  end

  config.vbguest.auto_update = false
end
