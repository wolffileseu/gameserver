# Wolffiles.eu Game Server Docker Image

[![Build and Push Docker Image](https://github.com/wolffileseu/gameserver/actions/workflows/build.yml/badge.svg)](https://github.com/wolffileseu/gameserver/actions/workflows/build.yml)

Pterodactyl-compatible Docker image based on Debian Bookworm with **32-bit library support**. Built for running classic game servers that require i386 binaries.

## Supported Games

| Game | Binary | Architecture |
|------|--------|-------------|
| ET: Legacy | `etlded` | i386 + x86_64 |
| ET 2.60b Classic | `etded.x86` | i386 |
| RtCW (iortcw) | `iowolfded.x86_64` | x86_64 |

## Usage in Pterodactyl

Set the Docker Image in your Egg to:

```
ghcr.io/wolffileseu/gameserver:latest
```

## What's included

- Debian Bookworm Slim
- Standard Pterodactyl dependencies (curl, tar, unzip, git, sqlite3, tini, etc.)
- **32-bit libraries** (`lib32gcc-s1`, `lib32stdc++6`, `libc6-i386`)
- Pterodactyl-compatible `container` user and entrypoint

## Building locally

```bash
git clone https://github.com/wolffileseu/gameserver.git
cd gameserver
docker build -t wolffileseu/gameserver:latest .
```

## Automated Builds

The image is automatically rebuilt:
- On every push to `main`
- Weekly (Monday 04:00 UTC) to keep base packages updated

## License

MIT
