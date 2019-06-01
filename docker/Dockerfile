FROM ubuntu:18.04

# System update
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        software-properties-common \
        git \
        zip \
        nano

# Bash profile
RUN mkdir /root/tmp \
    && cd /root/tmp \
    && git clone https://github.com/aleksa-sukovic/dotfiles.git \
    && cp ./dotfiles/src/remote/.profile /root/.profile \
    && echo "[[ -f /root/.profile ]] && . /root/.profile" >> /root/.bashrc \
    && rm -rf /root/tmp

# Custom scripts
COPY docker/scripts/love-functions.sh /root/.love-functions.sh
RUN echo "[[ -f /root/.love-functions.sh ]] && . /root/.love-functions.sh" >> /root/.bashrc

# Install Lua and Love
RUN apt-get install lua5.3 -y

RUN add-apt-repository ppa:bartbes/love-stable -y \
    && apt-get update -y \
    && apt-get install love -y

# Setup source
RUN mkdir /usr/src/app
COPY app /usr/src/app
