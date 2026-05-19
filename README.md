# Wolffiles.eu Game Server Docker Image

[![Build and Push Docker Image](https://github.com/wolffileseu/gameserver/actions/workflows/build.yml/badge.svg)](https://github.com/wolffileseu/gameserver/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Debian Bookworm](https://img.shields.io/badge/Debian-Bookworm-red.svg)](https://www.debian.org/releases/bookworm/)

Pterodactyl-compatible Docker images based on Debian Bookworm with **32-bit library support**. Built for running classic id Tech 3 era game servers — Enemy Territory, ET: Legacy, and Return to Castle Wolfenstein — including their mods and bot frameworks.

Powers the [Wolffiles.eu](https://wolffiles.eu) test server platform and game server hosting.

---

## Image Variants

Two variants are built and published from this repository:

| Tag | Purpose | Size (approx) |
|---|---|---|
| `ghcr.io/wolffileseu/gameserver:latest` | Linux-native game server binaries | ~450 MB |
| `ghcr.io/wolffileseu/gameserver:wine` | Windows-only mods via Wine + Xvfb | ~1.4 GB |

Pick `:latest` whenever a Linux `.so` / native binary exists for your mod. Use `:wine` only when a mod ships Windows-only (e.g. legacy Trickjump mods, private league builds, old fun-mods that were never ported).

Additional tags built from the same images:

- `:debian-bookworm` — alias for `:latest`
- `:wine-debian-bookworm` — alias for `:wine`

---

## Supported Games & Mods

### Native Linux (`:latest`)

| Game / Engine | Binary | Notes |
|---|---|---|
| ET: Legacy | `etlded.x86_64` / `etlded.x86` | Active development, current MP standard for ET |
| ET 2.60b Classic | `etded.x86` | Original Splash Damage release, 32-bit |
| iortcw | `iowolfded.x86` / `iowolfded.x86_64` | Modern RtCW source port |
| Vanilla RtCW 1.41b | `wolfded.x86` | Original id Software dedicated server |

Supported mods (both ET and RtCW): `etmain`, `legacy`, `etpub`, `etpro`, `silent`, `nitmod`, `noquarter`, `jaymod`, `etjump`, `tjmod`, `etrun`, `etnam`, `osp`, `shrub`, plus bot frameworks `omnibot` and `fritzbot`.

### Wine (`:wine`)

For Windows-only legacy mods that have no Linux equivalent:

| Game / Engine | Binary | Notes |
|---|---|---|
| RtCW Multiplayer | `WolfMP.exe` / `wolfDED.exe` | Vanilla 1.41b Windows engine under Wine |
| ET Multiplayer | `ET.exe` / `etded.exe` | Windows ET 2.60b engine under Wine |

Typical Windows-only mods: Bani, certain TJMod variants, older Omnibot Windows builds, Fritzbot Windows binaries.

---

## Usage in Pterodactyl

Set the Docker Image in your Egg to one of:

```
ghcr.io/wolffileseu/gameserver:latest    # Linux native
ghcr.io/wolffileseu/gameserver:wine      # Windows mods via Wine
```

Companion Pterodactyl eggs that pair with these images are published at [wolffileseu/eggs](https://github.com/wolffileseu/eggs) (RtCW Test Server, ET Test Server, ET:Legacy Test Server).

---

## What's Included

### Common to Both Variants

- Debian Bookworm Slim base
- Standard Pterodactyl dependencies: `curl`, `wget`, `tar`, `unzip`, `xz-utils`, `cabextract`, `p7zip-full`, `git`, `sqlite3`, `tini`
- Build toolchain: `gcc`, `g++`, `make`, `binutils`, `gdb`
- Networking & debugging: `iproute2`, `net-tools`, `netcat-openbsd`, `telnet`
- Media handling: `ffmpeg` (used for demo → video transcoding pipelines)
- **32-bit (i386) runtime libraries:**
  - `libc6:i386`, `libstdc++6:i386`, `libgcc-s1:i386`, `zlib1g:i386`
  - `lib32gcc-s1`, `lib32stdc++6`, `libc6-i386`
  - `liblua5.1-0:i386` (for Omnibot scripting)
  - `libjansson4:i386` (for RtcwPro stats JSON)
  - `libcurl4:i386` (for HTTP downloads from mods)
  - `libsdl2-2.0-0:i386`
- UTF-8 locale (`en_US.UTF-8`)
- Pterodactyl-compatible `container` user and `/entrypoint.sh`

### Additional in `:wine`

- **Wine** (`winehq-stable` from the official WineHQ repository)
- **Xvfb** + `xauth` — virtual X framebuffer for headless Wine
- **Winetricks** ([pelican-eggs fork](https://github.com/pelican-eggs/winetricks))
- **rcon-cli** (gorcon) for game server remote control
- `winbind`, `libntlm0`, `libncurses5/6:i386` — Wine prerequisites
- Pre-configured Wine defaults:
  - `WINEARCH=win32` (correct for legacy idTech3-era binaries)
  - `WINEPREFIX=/home/container/.wine`
  - `WINEDLLOVERRIDES="mscoree,mshtml="` (suppresses Mono/Gecko popups)
  - `XVFB=1` — entrypoint auto-starts Xvfb on `DISPLAY=:0`

---

## Building Locally

### Linux variant

```bash
git clone https://github.com/wolffileseu/gameserver.git
cd gameserver
docker build -t ghcr.io/wolffileseu/gameserver:latest -f Dockerfile .
```

### Wine variant

```bash
docker build -t ghcr.io/wolffileseu/gameserver:wine -f Dockerfile.wine .
```

### Quick sanity check

After building, verify the critical libraries are reachable:

```bash
# Linux variant
docker run --rm ghcr.io/wolffileseu/gameserver:latest bash -c "
  ldconfig -p | grep -E 'libjansson|libcurl|liblua5.1' | grep i386
"

# Wine variant
docker run --rm ghcr.io/wolffileseu/gameserver:wine bash -c "
  wine --version && which Xvfb && winetricks --version
"
```

---

## Automated Builds

Both image variants are built and pushed automatically via [GitHub Actions](.github/workflows/build.yml):

- On every push to `main`
- Weekly (Monday 04:00 UTC) to keep base packages and Wine up to date
- On manual workflow dispatch

Builds run in parallel using a matrix strategy with scoped GHA caches, so the Linux and Wine variants don't invalidate each other's apt layers.

---

## Repository Layout

```
gameserver/
├── Dockerfile              # Linux-native variant
├── Dockerfile.wine         # Wine variant
├── entrypoint.sh           # Linux-native entrypoint
├── entrypoint-wine.sh      # Wine entrypoint (starts Xvfb, inits prefix)
├── .github/workflows/
│   └── build.yml           # Matrix build + push
├── LICENSE                 # MIT
└── README.md
```

---

## License & Third-Party Notice

This Dockerfile, entrypoint scripts, and build configuration are **MIT-licensed** — see [LICENSE](LICENSE).

The image is intended to host third-party game server software. Game binaries, mods, maps, and bot waypoints are **NOT** bundled in this image and must be provided separately (e.g. via the Pterodactyl egg install script) in compliance with their respective licenses.

Runtime components:

- **Wine** (LGPL-2.1+) — https://www.winehq.org
- **Winetricks** (LGPL-2.1+, pelican-eggs fork)
- **Xvfb / xauth** (MIT)
- **rcon-cli** (MIT) — https://github.com/gorcon/rcon-cli
- **Debian Bookworm packages** — various licenses

Game / Mod / Bot copyrights:

- **Return to Castle Wolfenstein** © id Software / Activision — source code released under GPL-3.0 in 2010
- **Wolfenstein: Enemy Territory** © Splash Damage / id Software / Activision — freeware distribution, source under GPL-3.0
- **ET: Legacy** © ET:Legacy contributors — GPL-3.0 — https://github.com/etlegacy/etlegacy
- **iortcw** © iortcw contributors — GPL-3.0 — https://github.com/iortcw/iortcw
- **RtcwPro** © rtcwmp-com — GPL-3.0 — https://github.com/rtcwmp-com/rtcwPro
- **Omni-Bot** © Omni-Bot Team
- **Fritzbot** © Maleficus / Fritz Bot Team — Freeware
- **OSP, ETPub, NoQuarter, Silent, ETPro, NitMod, Jaymod, ETJump, TJMod, ETNam, ETRun, Bani, Shrub** belong to their respective authors

Operators of derived images are responsible for ensuring their use of the game binaries and mod files complies with the upstream license terms, including (but not limited to) any GPL source-distribution obligations.

---

## Links

- **Wolffiles.eu** — https://wolffiles.eu
- **Wolffiles Eggs Repository** — https://github.com/wolffileseu/eggs
- **GitHub Container Registry** — https://github.com/wolffileseu/gameserver/pkgs/container/gameserver
- **Issues / Feature Requests** — https://github.com/wolffileseu/gameserver/issues

## Maintainer

[Wolffiles.eu](https://wolffiles.eu) — admin@wolffiles.eu
