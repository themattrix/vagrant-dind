Docker-in-Docker in Vagrant
===========================

My continuously-evolving development box.

First time use:

```
$ git clone https://github.com/themattrix/vagrant-dind.git
$ cd vagrant-dind
$ # Optionally create a .ssh directory here. See "SSH Config" below.
$ vagrant up
$ vagrant ssh
```

At this point you'll be sitting in a tmux session, which is running in
a single-session docker container. Exiting or disconnecting the session will
cause the container to be destroyed. When the container is destroyed, only
three things survive:

1. The `/repos` directory, which is provided as a work area.
2. The `/home/.ssh` directory, which allows for persistent changes to things
3. like `authorized_keys`.
3. Docker images and containers.

In this way, you can be sure to always start with a clean environment,
but your work area and any docker images and containers will persist
between sessions.


## Architecture


    $ vagrant up
    $ vagrant ssh

    .--[ Vagrant: boot2docker ]----------------------.
    |                                                |
    | <autorun.sh>                                   |
    |                                                |
    | .--[ docker (privileged): ubuntu:14.04 ]------.|
    | |  _______________________________________[0] ||
    | |  root@c23311ce9a9f [/]                      ||
    | |  #                                          ||
    | '---------------------------------------------'|
    '------------------------------------------------'


## SSH Config

In order to make SSH operations useful inside the development container, you
may optionally provide a `.ssh` directory to it by placing it at the root of
the `vagrant-dind` directory. This will then be copied into the VM and provided
as a volume to the development container.


## How do I...

**...update my SSH config inside the development container?**

> Assuming you've updated the `vagrant-dind/.ssh` directory as described
> in the *SSH Config* section above, the solution is to either reload
> or re-provision the Vagrant box.


**...install additional packages into the development container?**

> In your current session:
>
> - `apt-get install <package>`
> 
> 
> For all future sessions:
> 
> 1. Modify `vagrant-dind/app/Dockerfile` to install the package. It's
> probably easiest to include it in one of the existing `apt-get install`
> commands.
> 2. Reload or re-provision the Vagrant box.


**...clone a repo and get started changing it?**

> If you'd like the repo to stick around for longer than the current session,
> clone the repo into `/repos`. This directory is mapped to a persistent area
> in the boot2docker VM and will survive until the VM is deleted.


**...add or change the persistent directories?**

> `vagrant-dind/autorun.sh` contains the `docker run` command which lauches
> the development container when you SSH into the Vagrant box. This command
> contains several volumes mounted into the container (in the form
> `-v /vm/dir:/container/dir`). Feel free to add as many additional volumes
> as you'd like.
>
> Be sure to consider the following:
>
> - Since the VM is a boot2docker instance, only the `/mnt/sda` directory
> persists across reboots of the VM. If you'd like your volume to persist
> across reboots of the VM as well, then consider making the source of the
> mount a subdirectory of `/mnt/sda`. (This is exactly what the `/repos`
> volume does.)
>
> Like the other permanent changes, this will require Vagrant to either be
> reloaded or re-provisioned.


**...run a one-time command in the boot2docker VM instead of automatically entering the development container?**

> `vagrant ssh -c '<your-command>'`
>
> If your development container ever gets messed up, this can be a life saver.


**...develop outside of the development container, but run things inside it?**

> My current technique is to set my IDE (PyCharm, in my case) to deploy files
> to the Vagrant box in a subdirectory of `/mnt/sda/repos/`. I then have
> a Vagrant ssh session open, from which I can run anything from the command
> line.
