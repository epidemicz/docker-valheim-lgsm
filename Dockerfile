FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

ARG SERVER_PASSWORD=supersecret
ARG user=vhserver

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y apt-utils 

# install steamcmd and accept the shitty license agreement prompt
RUN echo steam steam/question select "I AGREE" | debconf-set-selections

# dependencies
RUN apt-get install -qq sudo curl git wget file tar bzip2 gzip unzip bsdmainutils \ 
python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 \ 
lib32stdc++6 libsdl2-2.0-0:i386 lib32z1 steamcmd cpio xz-utils libc6-dev

# Create server user
RUN useradd -m $user && echo "${user}:${user}" | chpasswd && adduser $user sudo

# switch to server home
WORKDIR /home/$user

# download linuxgsm
RUN wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh

# switch to server user and install server
USER $user
RUN ./linuxgsm.sh $user
RUN ./$user auto-install

# set password
RUN echo "serverpassword=\"$SERVER_PASSWORD\"" >> /home/$user/lgsm/config-lgsm/vhserver/vhserver.cfg 

# game server port
EXPOSE 2456/udp

# query port
EXPOSE 2457/udp