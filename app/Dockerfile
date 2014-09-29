FROM ubuntu:14.04

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y install \
        python-software-properties software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository -y ppa:rudenko/neovim

RUN apt-get update \
    && apt-get -y install \
        iptables ca-certificates lxc apt-transport-https \
        tmux git neovim htop socat man ruby \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin/docker /usr/local/bin/docker
ADD ./bin/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker

ENV HOME /home
ENV ET_CLONE_HOME 2014-09-29 14:05 CST
RUN git clone https://github.com/themattrix/home.git
RUN echo 'source ~/.bashrc' >> /home/.bash_profile

RUN mkdir -p /home/.nvim/autoload \
    && wget -q -O /home/.nvim/autoload/plug.vim \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN nvim -u /home/.vim_plug -c 'PlugInstall|q!|q!' > /dev/null

CMD ["wrapdocker"]
