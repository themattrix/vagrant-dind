FROM ubuntu:14.04

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y install \
        python-software-properties software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository -y ppa:rudenko/neovim
RUN add-apt-repository -y ppa:ultradvorka/ppa

RUN apt-get update \
    && apt-get -y install \
        iptables ca-certificates lxc apt-transport-https \
        tmux git neovim htop socat man ruby hh bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Change the home directory of the root user to /home
ENV HOME /home
RUN sed -r -i -e 's@^root:.*@root:x:0:0:root:/home:/bin/bash@' /etc/passwd \
    && rm -rf /root

# Check out a specific commit - this has the advantage of invalidating the
# cache for this RUN command whenever we want to update this repo.
RUN git clone https://github.com/themattrix/home.git \
    && cd /home \
    && git checkout 7bcf4a1

RUN echo 'source ~/.bashrc' >> /home/.bash_profile

# Add fig: "Fast, isolated development environments using Docker"
ADD https://github.com/docker/fig/releases/download/0.5.2/linux \
    /usr/local/bin/fig
RUN chmod +x /usr/local/bin/fig

ADD https://raw.githubusercontent.com/junegunn/vim-plug/0.5.7/plug.vim \
    /home/.nvim/autoload/plug.vim

RUN nvim -u /home/.vim_plug -c 'PlugInstall|q!|q!' > /dev/null

# Add docker from the external environment
ADD ./bin/docker /usr/local/bin/docker
ADD ./bin/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker

CMD ["wrapdocker"]
