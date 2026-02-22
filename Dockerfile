FROM debian:bookworm-slim

LABEL author="Wolffiles.eu"
LABEL maintainer="wahke@wolffiles.eu"
LABEL org.opencontainers.image.source="https://github.com/wolffileseu/gameserver"
LABEL org.opencontainers.image.description="Wolffiles.eu Game Server Image - Debian with 32-bit support for ET/ET:Legacy/RtCW"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive

## Create container user (required by Pterodactyl)
RUN useradd -m -d /home/container -s /bin/bash container

RUN ln -s /home/container/ /nonexistent

ENV USER=container HOME=/home/container

## Update base packages
RUN apt update \
    && apt upgrade -y

## Install dependencies (standard Pterodactyl deps + 32-bit libs)
RUN apt install -y \
    ## Standard Pterodactyl dependencies
    curl \
    ca-certificates \
    openssl \
    git \
    tar \
    unzip \
    sqlite3 \
    tzdata \
    iproute2 \
    tini \
    ## 32-bit support (required for ET 2.60b, ET:Legacy i386, RtCW)
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    ## Cleanup
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

USER container
WORKDIR /home/container

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
