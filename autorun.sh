#!/bin/sh

docker run -i -t --rm --privileged=true \
    -v /mnt/sda/var/lib/docker-inner:/var/lib/docker \
    -v /mnt/sda/repos:/repos \
    -v /home/docker/.ssh-inner:/home/.ssh \
    develop
