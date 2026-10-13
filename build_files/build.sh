#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

## Configurazioni di sistema

# --- DNF SPEEDUP ---
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

# --- IWD ---
dnf remove -y wpa_supplicant
dnf install -y iwd

# --- COPR ---
dnf -y install dnf-plugins-core

# --- OTHER ---
dnf install -y \
    htop \
    nvtop \
    fastfetch

# --- VULKAN AND LLAMA-CPP ---
dnf copr enable -y sneed/llama-cpp-vulkan
dnf install -y \
    mesa-dri-drivers \
    mesa-vulkan-drivers \
    vulkan-loader \
    vulkan-tools \
    clinfo \
    llama-cpp

# --- DOCKER ---
dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
dnf remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine
dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker-ce-rootless-extras
