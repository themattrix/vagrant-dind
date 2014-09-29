#!/bin/sh

docker run -i -t --rm --privileged=true \
    -v /vagrant/app:/app \
    -v /mnt/sda/var/lib/docker-inner:/var/lib/docker \
    develop
