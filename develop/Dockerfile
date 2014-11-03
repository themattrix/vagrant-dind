FROM ubuntu:14.04

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y install \
        python-software-properties software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository -y ppa:ultradvorka/ppa

RUN apt-get update \
    && apt-get -y install \
        iptables ca-certificates lxc apt-transport-https \
        tmux git vim htop socat man ruby hh bash-completion \
        curl python-pygments vim-youcompleteme \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Can't live without rainbow-colored output
RUN gem install lolcat

# Install Rust and Cargo
RUN curl https://raw.githubusercontent.com/rust-lang/rust/9106546aa7d56dcaf650d9bc03fe5b5c3cf3460d/src/etc/rustup.sh | bash

# Change the home directory of the root user to /home
ENV HOME /home
ENV USER root
RUN sed -r -i -e 's@^root:.*@root:x:0:0:root:/home:/bin/bash@' /etc/passwd \
    && rm -rf /root

# Store the bash history to its own directory so that we can mount a volume
# to that location and have the history preserved across sessions.
ENV HISTFILE /home/.bash_history/history

# Check out a specific commit - this has the advantage of invalidating the
# cache for this RUN command whenever we want to update this repo.
RUN git clone https://github.com/themattrix/home.git \
    && cd /home \
    && git checkout 7e65c56

# Set locale
RUN locale-gen en_US.UTF-8 && /usr/sbin/update-locale LANG=en_US.UTF-8

RUN echo 'source ~/.bashrc' >> /home/.bash_profile

# Add fig: "Fast, isolated development environments using Docker"
RUN wget -O /usr/local/bin/fig https://github.com/docker/fig/releases/download/1.0.0/fig-`uname -s`-`uname -m` \
    && chmod +x /usr/local/bin/fig

ADD https://raw.githubusercontent.com/junegunn/vim-plug/0.5.7/plug.vim \
    /home/.vim/autoload/plug.vim

# Install vim plugins
RUN vim -u /home/.vim_plug -c 'PlugInstall|q!|q!' > /dev/null
RUN vam install youcompleteme

# Add docker from the external environment
ADD ./bin/docker /usr/local/bin/docker
ADD ./bin/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker

CMD ["wrapdocker"]
