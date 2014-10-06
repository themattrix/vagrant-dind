#!/bin/sh

docker run -i -t --rm --privileged=true \
    -v /mnt/sda/var/lib/docker-inner:/var/lib/docker \
    -v /mnt/sda/repos:/repos \
    -v /mnt/sda/history:/home/.bash_history \
    -v /home/docker/.ssh-inner:/home/.ssh \
    -v /vagrant:/vagrant \
    develop
