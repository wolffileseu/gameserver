FROM debian:bookworm-slim

LABEL author="Wolffiles.eu"
LABEL maintainer="admin@wolffiles.eu"
LABEL org.opencontainers.image.source="https://github.com/wolffileseu/gameserver"
LABEL org.opencontainers.image.description="Wolffiles.eu Game Server Image - Debian Bookworm with 32-bit support for ET/ET:Legacy/RtCW"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive

# Create container user required by Pterodactyl
RUN useradd -m -d /home/container -s /bin/bash container \
    && ln -s /home/container/ /nonexistent

ENV USER=container
ENV HOME=/home/container

# Update base system and install dependencies
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        wget \
        git \
        tar \
        zip \
        unzip \
        xz-utils \
        binutils \
        cabextract \
        iproute2 \
        net-tools \
        netcat-openbsd \
        telnet \
        tzdata \
        locales \
        tini \
        sqlite3 \
        libsqlite3-dev \
        ffmpeg \
        gnupg2 \
        apt-transport-https \
        software-properties-common \
        gcc \
        g++ \
        gdb \
        make \
        libc6 \
        libgcc-s1 \
        libatomic1 \
        liblzo2-2 \
        libsdl1.2debian \
        libsdl2-2.0-0 \
        libfontconfig1 \
        libicu72 \
        libunwind8 \
        libssl-dev \
        libmariadb-dev \
        libduktape207 \
        liblua5.1-0 \
        liblua5.1-0:i386 \
        liblua5.1-0-dev \
        liblua5.1-0-dev:i386 \
        liblua5.3-0 \
        liblua5.3-dev \
        zlib1g \
        zlib1g-dev \
        rapidjson-dev \
        lib32gcc-s1 \
        lib32stdc++6 \
        libc6-i386 \
        libc6:i386 \
        libstdc++6:i386 \
        libgcc-s1:i386 \
        zlib1g:i386 \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

USER container
WORKDIR /home/container

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
