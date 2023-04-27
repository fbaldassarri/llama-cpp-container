# Dockerfile to deploy a llama-cpp container 

# Default TAG=latest
# docker pull continuumio/miniconda3:latest

ARG TAG=latest
# FROM continuumio/miniconda3:$TAG as builder
FROM continuumio/miniconda3:$TAG 

# RUN sed -i -E 's/^# deb-src /deb-src /g' /etc/apt/sources.list \
#     && apt-get update \
#     && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
#         build-essential \
#         dpkg-dev \
#         git \
#         libpulse-dev \
#         pulseaudio \
#     && apt-get build-dep -y pulseaudio \
#     && apt-get source pulseaudio \
#     && rm -rf /var/lib/apt/lists/*

# RUN cd /pulseaudio-$(pulseaudio --version | awk '{print $2}') \
#     && ./configure

# RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /pulseaudio-module-xrdp \
#     && cd /pulseaudio-module-xrdp \
#     && ./bootstrap \
#     && ./configure PULSE_DIR=/pulseaudio-$(pulseaudio --version | awk '{print $2}') \
#     && make \
#     && make install


# Build the final image
# FROM ubuntu:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        wget \
        openssh-server \
        nano \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# SSH exposition

EXPOSE 22/tcp
RUN service ssh start

# Create user

RUN groupadd --gid 1020 llama-cpp-group
# RUN useradd -m llama-cpp-user -g users
RUN useradd -rm -d /home/llama-cpp-user -s /bin/bash -G users,sudo,llama-cpp-group -u 1000 llama-cpp-user
# RUN usermod -aG sudo,users llama-cpp-user

# COPY --from=builder /usr/lib/pulse-*/modules/module-xrdp-sink.so /usr/lib/pulse-*/modules/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer/
# COPY entrypoint.sh /usr/bin/entrypoint
# RUN chmod 755 /usr/bin/entrypoint
# ENTRYPOINT ["/usr/bin/entrypoint"]

# Update user password
RUN echo 'llama-cpp-user:admin' | chpasswd

# Adding ownership of /opt/conda to $user

RUN chown -R llama-cpp-user:users /opt/conda

# conda init bash for $user
RUN su - llama-cpp-user -c "conda init bash"

# Updating conda to the latest version
RUN su - llama-cpp-user -c "conda update conda -y"

# Run shell
CMD ["/bin/bash"]

# Create virtalenv

RUN conda create -n llamacpp -y python=3.10.6

# Download latest github/llama-cpp in llama-cpp directory

# Download model


