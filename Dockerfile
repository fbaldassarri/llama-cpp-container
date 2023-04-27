# Dockerfile to deploy a llama-cpp container with conda-ready environments 

# docker pull continuumio/miniconda3:latest

ARG TAG=latest
FROM continuumio/miniconda3:$TAG 

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
RUN useradd -rm -d /home/llama-cpp-user -s /bin/bash -G users,sudo,llama-cpp-group -u 1000 llama-cpp-user

# Update user password
RUN echo 'llama-cpp-user:admin' | chpasswd

# Updating conda to the latest version
RUN conda update conda -y

# Create virtalenv
RUN conda create -n llamacpp -y python=3.10.6

# Adding ownership of /opt/conda to $user
RUN chown -R llama-cpp-user:users /opt/conda

# conda init bash for $user
RUN su - llama-cpp-user -c "conda init bash"

# Download latest github/llama-cpp in llama.cpp directory and compile it
RUN su - llama-cpp-user -c "git clone https://github.com/ggerganov/llama.cpp.git ~/llama.cpp \
                            && cd ~/llama.cpp \
                            && make "

# Install Requirements for python virtualenv
RUN su - llama-cpp-user -c "cd ~/llama.cpp \
                            && conda activate llamacpp \
                            && python3 -m pip install -r requirements.txt " 

# Download model
# RUN su - llama-cpp-user -c "https://github.com/facebookresearch/llama.git ~/llama \
#                            && cd ~/llama \
#                            && ./download.sh "

# COPY entrypoint.sh /usr/bin/entrypoint
# RUN chmod 755 /usr/bin/entrypoint
# ENTRYPOINT ["/usr/bin/entrypoint"]

# Preparing for login
ENV HOME /home/llama-cpp-user
WORKDIR ${HOME}/llama.cpp
USER llama-cpp-user
CMD ["/bin/bash"]
