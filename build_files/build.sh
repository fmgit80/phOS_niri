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
    fastfetch \
    alacritty \
    xed \
    cliphist \
    wl-clipboard

# --- RETE, WI-FI & BLUETOOTH ---
dnf install -y \
    NetworkManager \
    NetworkManager-wifi \
    linux-firmware \
    iwlwifi-mvm-firmware \
    iwlwifi-dvm-firmware \
    iwlwifi-mld-firmware \
    iwlegacy-firmware \
    bluez \
    bluez-tools

# --- NIRI AND NOCTALIA ---
##dnf copr enable -y avengemedia/danklinux
##dnf copr enable -y avengemedia/dms
dnf install -y \
    xdg-utils \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-wlr \
    gnome-keyring \
    wayland-utils \
    xwayland-satellite \
    xorg-x11-server-Xwayland \
    niri \
    noctalia

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

# --- DISTROBOX ---
dnf install -y \
    distrobox

# --- CLEANING ---
dnf remove -y \
    blueman \
    network-manager-applet

# Imposta i permessi corretti per gli script di sync dotfiles e forza l'attivazione del sync dotfiles all'interno del target grafico globale utente
ln -s /dev/null /usr/lib/systemd/system/wpa_supplicant.service
chmod +x /usr/bin/phos-niri-dotfiles-sync
mkdir -p /usr/lib/systemd/user/graphical-session.target.wants
ln -sf /usr/lib/systemd/user/dotfiles.service /usr/lib/systemd/user/graphical-session.target.wants/dotfiles.service

