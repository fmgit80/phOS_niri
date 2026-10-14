# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files
# Copia la configurazione dei portali all'interno di /usr/share per renderla
# un default di sistema pulito ed evitare conflitti futuri con l'utente in /etc
#COPY config/etc/xdg-desktop-portal/niri-portals.conf /usr/share/xdg-desktop-portal/niri-portals.conf

FROM quay.io/fedora-ostree-desktops/sway-atomic:44

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

RUN bootc container lint
