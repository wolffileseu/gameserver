# ============================================================================
# Wolffiles.eu Game Server Image
# ----------------------------------------------------------------------------
# Copyright (c) 2026 Wolffiles.eu (Wahke / Kevin)
# Licensed under the MIT License - see LICENSE file in repository root.
#
# Repository:    https://github.com/wolffileseu/gameserver
# Maintainer:    admin@wolffiles.eu
# Description:   Debian Bookworm base image with multi-architecture (x86_64
#                + i386) support for hosting dedicated game servers of
#                Wolfenstein: Enemy Territory, ET: Legacy, and Return to
#                Castle Wolfenstein, including their respective mods.
#
# ----------------------------------------------------------------------------
# Third-Party Software Notice
# ----------------------------------------------------------------------------
# This image is intended to host third-party game server software. The game
# binaries, mods, maps, and bot waypoints are NOT bundled in this image and
# must be provided separately (e.g. via the Pterodactyl egg install script)
# in compliance with their respective licenses.
#
# Game / Mod / Bot copyrights:
#   - Return to Castle Wolfenstein (c) id Software / Activision
#       Source code released under GPL-3.0 in 2010.
#   - Wolfenstein: Enemy Territory (c) Splash Damage / id Software / Activision
#       Freeware distribution, source under GPL-3.0.
#   - ET: Legacy (c) ET:Legacy contributors - GPL-3.0
#       https://github.com/etlegacy/etlegacy
#   - iortcw (c) iortcw contributors - GPL-3.0
#       https://github.com/iortcw/iortcw
#   - RtcwPro (c) rtcwmp-com - GPL-3.0
#       https://github.com/rtcwmp-com/rtcwPro
#   - Omni-Bot (c) Omni-Bot Team - Custom license, free for non-commercial use
#   - Fritzbot (c) Maleficus / Fritz Bot Team - Freeware
#   - OSP, ETPub, NoQuarter, Silent, ETPro, NitMod, Jaymod, ETJump, TJMod,
#     ETNam, ETRun and other mods belong to their respective authors.
#
# This Dockerfile and the entrypoint script are MIT-licensed; the runtime
# software composed inside the container retains its original license.
#
# Operators of derived images are responsible for ensuring their use of the
# game binaries and mod files complies with the upstream license terms,
# including (but not limited to) any GPL source-distribution obligations.
# ============================================================================

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="Wolffiles.eu Game Server"
LABEL org.opencontainers.image.description="Debian Bookworm with 32-bit support for ET / ET:Legacy / RtCW dedicated servers"
LABEL org.opencontainers.image.authors="admin@wolffiles.eu"
LABEL org.opencontainers.image.vendor="Wolffiles.eu"
LABEL org.opencontainers.image.source="https://github.com/wolffileseu/gameserver"
LABEL org.opencontainers.image.url="https://wolffiles.eu"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------------------------------------------
# Pterodactyl-required container user
# ----------------------------------------------------------------------------
RUN useradd -m -d /home/container -s /bin/bash container \
    && ln -s /home/container/ /nonexistent

ENV USER=container
ENV HOME=/home/container

# ----------------------------------------------------------------------------
# System packages
#
# Includes 32-bit (i386) runtime libraries needed for legacy idTech3 game
# binaries (wolfded.x86, etlded.x86, etl.x86) and 32-bit mod libraries
# (qagame.mp.i386.so, omnibot, fritzbot, etc.).
# ----------------------------------------------------------------------------
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
        # RtCW / RtcwPro runtime dependencies
        libjansson4 \
        libjansson4:i386 \
        libcurl4 \
        libcurl4:i386 \
        # 32-bit base runtime for ET/RtCW dedicated binaries
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
