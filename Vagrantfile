VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.6.3"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "boot2docker"
  config.vm.box = "codekitchen/boot2docker"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/vagrant"
  config.vm.network "forwarded_port", guest: 8888, host: 8888

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

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

  # Ensure that SSH'ing into the Vagrant box launches the development environment.
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
      set -e

      chmod u+x /home/docker/autorun.sh

      if ! grep -sqF "autorun.sh" /home/docker/.ashrc; then
        {
          echo
          echo "export PERSIST_DIR=/mnt/sda1/persist"
          echo "export RESTORE_TAR=/vagrant/.restore.tar"
          echo "exec /home/docker/autorun.sh"
        } >> /home/docker/.ashrc
      fi
    EOT
  end

  # Ensure that the docker binary is available to the dev environment Dockerfile
  config.vm.provision "shell", inline: 'cp /usr/local/bin/docker /vagrant/develop/bin/docker'

  # Create the /mnt/sda1/persist directory if it does not already exist. If a
  # /vagrant/.restore.tar.gz file exists and the persist directory does not,
  # the restore archive will be extracted to the persist directory.
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
      set -e

      persist_dir=/mnt/sda1/persist
      restore_tar=/vagrant/.restore.tar
      persist_ssh="${persist_dir}/home/.ssh"

      if [ ! -d "${persist_dir}" ]; then
        if [ -f "${restore_tar}" ]; then
          tar -C "$(dirname "${persist_dir}")" -xf "${restore_tar}"
        else
          mkdir -p "${persist_dir}/var/lib/docker"
          mkdir -p "${persist_dir}/repos"
          mkdir -p "${persist_dir}/home/.bash_history"
          mkdir -p "${persist_dir}/home/.ssh"
        fi
      fi

      chown docker:staff "${persist_dir}"

      # Copy new ssh keys into the VM.
      if [ -d /vagrant/.ssh ]; then
        mkdir -p "${persist_ssh}"
        cp -f /vagrant/.ssh/* "${persist_ssh}"
      fi

      # Always ensure that the .ssh directory has correct attributes.
      (
        cd "${persist_ssh}"
        {
          chmod -f 700 .
          chown -R root:root .
          set +e
          chmod -f 600 *
          chmod -f 644 *.pub
          chmod -f 640 authorized_keys
          chmod -f 644 known_hosts
        } &> /dev/null
      )

      # Always ensure that the repos directory has correct attributes.
      chown root:docker "${persist_dir}/repos"
      chmod 775 "${persist_dir}/repos"
    EOT
  end

  # Build the docker image containing the development environment
  config.vm.provision :docker do |d|
    d.build_image "/vagrant/develop", args: "-t develop"
  end

  # Delete all untagged images that aren't in use.
  config.vm.provision :shell, run: "always" do |s|
    s.inline = <<-EOT
        stopped_containers=$(docker ps -a | grep 'Exited' | awk '{print $1}')
        untagged_images=$(docker images | grep '^<none>' | awk '{print $3}')

        if [ -n "${stopped_containers}" ]; then
            echo ">>> Removing stopped containers..."
            docker rm ${stopped_containers}
        fi

        if [ -n "${untagged_images}" ]; then
            echo ">>> Removing untagged images..."
            docker rmi ${untagged_images}
        fi
    EOT
  end

  # Don't try to update the VirtualBox guest additions.
  config.vbguest.auto_update = false
end
