#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

## Configurazioni di sistema

# --- DNF SPEEDUP ---
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

# --- Installazione repo RPM fusion ---
FEDORA_VERSION=$(sh -c '. /etc/os-release; echo $VERSION_ID')
rpm --import https://mirrors.rpmfusion.org/free/fedora/RPM-GPG-KEY-rpmfusion-free-fedora-${FEDORA_VERSION}
rpm --import https://mirrors.rpmfusion.org/nonfree/fedora/RPM-GPG-KEY-rpmfusion-nonfree-fedora-${FEDORA_VERSION}
dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm

# --- IWD ---
dnf remove -y wpa_supplicant
dnf install -y iwd
ln -s /dev/null /usr/lib/systemd/system/wpa_supplicant.service

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

# Imposta i permessi per gli script personalizzati in runtime
##chmod +x /usr/bin/phos-niri-dotfiles-sync
##chmod +x /usr/bin/docker-autorootless
##for bash_file in /ctx/system_files/./usr/bin/*; do
for bash_file in /ctx/system_files/usr/bin/*; do
    if [ -f "$bash_file" ]; then
        bash_name=$(basename "$bash_file")
        echo "Impostazione permessi di: $bash_name"
        chmod +x /usr/bin/$bash_name
    fi
done

# Crea i link simbolici nel target grafico globale utente
USER_WANTS_DIR="/usr/lib/systemd/user/graphical-session.target.wants"
mkdir -p "$USER_WANTS_DIR"
##for service_file in /ctx/system_files/./usr/lib/systemd/user/*.service; do
for service_file in /ctx/system_files/usr/lib/systemd/user/*.service; do
    service_name=$(basename "$service_file")
    echo "Abilitazione globale di: $service_name"
    ln -sf "/usr/lib/systemd/user/$service_name" "$USER_WANTS_DIR/$service_name"
done

# Aggiunge Flathub come repository globale di sistema (accessibile a tutti gli utenti)
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
