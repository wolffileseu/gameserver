#!/bin/bash
# ============================================================================
# Wolffiles.eu Game Server (Wine) - entrypoint
# Copyright (c) 2026 Wolffiles.eu | MIT-licensed
# ============================================================================
#
# This entrypoint is responsible for:
#   1. Starting an Xvfb virtual display (if XVFB=1) so Wine can run headless.
#   2. Initializing the Wine prefix on first start (silent, no popups).
#   3. Substituting Pterodactyl's {{VAR}} placeholders in the STARTUP string.
#   4. Executing the resulting command and forwarding stdin (so the panel
#      can issue 'quit' / RCON commands through the console).
# ============================================================================

cd /home/container || exit 1

# ----------------------------------------------------------------------------
# Console banner
# ----------------------------------------------------------------------------
echo "================================================"
echo " Wolffiles.eu Game Server (Wine)"
echo " $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo " Wine: $(wine --version 2>/dev/null || echo 'not found')"
echo " Arch: ${WINEARCH:-win32}"
echo "================================================"

# ----------------------------------------------------------------------------
# Start Xvfb if requested (XVFB=1, the default)
#
# Pterodactyl Wine yolk convention: XVFB=1 → start a virtual X server on the
# DISPLAY variable. We do the same so this entrypoint stays a drop-in
# replacement.
# ----------------------------------------------------------------------------
if [ "${XVFB:-1}" = "1" ]; then
    DISPLAY_NUM="${DISPLAY:-:0}"
    SCREEN_SIZE="${DISPLAY_WIDTH:-800}x${DISPLAY_HEIGHT:-600}x${DISPLAY_DEPTH:-16}"
    echo "[entrypoint] Starting Xvfb on ${DISPLAY_NUM} (${SCREEN_SIZE})..."
    Xvfb "${DISPLAY_NUM}" -screen 0 "${SCREEN_SIZE}" -nolisten tcp -nolisten unix >/dev/null 2>&1 &
    XVFB_PID=$!
    # Give Xvfb a moment to come up
    sleep 1
    if ! kill -0 ${XVFB_PID} 2>/dev/null; then
        echo "[entrypoint] WARNING: Xvfb failed to start - Wine may not work correctly"
    fi
fi

# ----------------------------------------------------------------------------
# Initialize Wine prefix on first start
#
# wineboot --init creates ~/.wine if it doesn't exist. We swallow its output
# because it spews registry-creation noise that's not useful in logs.
# ----------------------------------------------------------------------------
if [ ! -d "${WINEPREFIX:-/home/container/.wine}" ]; then
    echo "[entrypoint] Initializing Wine prefix (${WINEARCH:-win32}) - first run only..."
    wineboot --init >/dev/null 2>&1 || true
    # Wait for wineserver background processes to settle
    wineserver -w 2>/dev/null || true
    echo "[entrypoint] Wine prefix ready."
fi

# ----------------------------------------------------------------------------
# IP / Port info for the panel log
# ----------------------------------------------------------------------------
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP
echo "[entrypoint] Internal IP: ${INTERNAL_IP:-unknown}"

# ----------------------------------------------------------------------------
# Substitute Pterodactyl {{VAR}} placeholders in STARTUP
#
# Pterodactyl passes the startup string with {{VAR}} markers; we convert
# them to ${VAR} so bash can expand them against the environment.
# ----------------------------------------------------------------------------
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
MODIFIED_STARTUP=$(eval echo "${MODIFIED_STARTUP}")

echo ":/home/container$ ${MODIFIED_STARTUP}"

# ----------------------------------------------------------------------------
# Run the game server
#
# exec replaces the shell so tini can deliver signals (SIGINT for graceful
# stop, SIGTERM for kill) directly to wine / the game process.
# ----------------------------------------------------------------------------
exec ${MODIFIED_STARTUP}
