# CrazyNoisyBizarreCraft

Modpack files for our server, kept in git so mod updates sync reliably (no
more `.mrpack` downloads silently failing).

## First-time setup

One-time only: install [Git](https://git-scm.com/downloads) and
[Git LFS](https://git-lfs.com/) if you don't already have them.

Then download the setup script for your OS and run it (double-click):

- **Windows**: [setup.bat](https://raw.githubusercontent.com/ccallisto/CrazyNoisyBizarreCraft/main/setup.bat)
- **Mac**: [setup.command](https://raw.githubusercontent.com/ccallisto/CrazyNoisyBizarreCraft/main/setup.command)
  — first launch may need a right-click → Open to get past Gatekeeper
- **Linux**: [setup.sh](https://raw.githubusercontent.com/ccallisto/CrazyNoisyBizarreCraft/main/setup.sh)

It clones the pack straight into your PrismLauncher instances folder. Open
(or restart) PrismLauncher afterward and the instance shows up automatically.

## Getting updates

Inside the instance folder, run `update.bat` (Windows), `update.command`
(Mac), or `update.sh` (Linux) — same one that came with the clone. It pulls
whatever changed (new/updated/removed mods, config, shaderpacks) and leaves
your saves, screenshots, keybinds, and JVM/memory settings untouched.

If it ever says the update "didn't apply cleanly," stop and ask before
running anything else — that means something local conflicts with the
update.

## What's tracked vs. not

Tracked (synced to everyone): `mods/`, `config/`, `shaderpacks/`,
`mmc-pack.json` (loader/MC version).

Not tracked (stays local/personal): saves, screenshots, logs, minimap data,
`instance.cfg` (Java path/RAM/playtime), `options.txt` (keybinds/video
settings), Distant Horizons world cache.
