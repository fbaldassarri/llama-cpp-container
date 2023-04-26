#!/usr/bin/env bash

# Create the user account
# groupadd --gid 1020 ubuntu
# useradd --shell /bin/bash --uid 1020 --gid 1020 --password $(openssl passwd ubuntu) --create-home --home-dir /home/ubuntu ubuntu
# usermod -aG sudo ubuntu

groupadd --gid 1020 llama-cpp-user
useradd --shell /bin/bash --uid 1020 --gid 1020 --password $(openssl passwd llama) --create-home --home-dir /home/llama-cpp-user llama-cpp-user
usermod -aG sudo llama-cpp-user

# Start xrdp sesman service
# /usr/sbin/xrdp-sesman

# Run xrdp in foreground if no commands specified
# if [ -z "$1" ]; then
#     /usr/sbin/xrdp --nodaemon
# else
#     /usr/sbin/xrdp
#     exec "$@"
# fi
