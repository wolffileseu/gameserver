#!/bin/bash

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Print startup info
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mWolffiles.eu Game Server\n"
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mArch: $(uname -m) | 32-bit support: $([ -f /lib/ld-linux.so.2 ] && echo 'YES' || echo 'NO')\n"

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"

# Run the server
eval "$PARSED"
