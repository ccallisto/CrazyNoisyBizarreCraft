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

You shouldn't have to do anything. The pack updates itself every time you
press Play in PrismLauncher, before the game starts, so you are always on
the same mods as everyone else.

What you'll notice: pressing Play takes a second or two longer than it used
to. After a big update it takes longer still, because it's downloading. Then
the game starts as normal.

If something goes wrong, the pack does **not** stop you playing. Offline, or
GitHub having a bad day, just means you launch on the mods you already have
and it tries again next time. A console window opens to say so. The only
thing that matters is that you can't join the server on the wrong mods, and
the server tells you that itself.

You can still run the update by hand any time: `update.bat` (Windows),
`update.command` (Mac), or `update.sh` (Linux) in the instance folder. That
is also how you switch automatic updates on if you set the pack up before
this feature existed.

If it ever says the update "didn't apply cleanly", stop and ask before
running anything else. That means something local conflicts with the update.

## One-time step when updating past "Stop tracking per-player client config"

That update changes which files git manages, so the older `update` script
can't apply it and will say the update "didn't apply cleanly". Run the new
script directly once, from inside the instance folder. It keeps your video
and shader settings, and switches on the automatic updating described above.

**Mac/Linux** (Terminal, in the instance folder):

```
git fetch origin && git show origin/main:update.sh > update-new.sh && chmod +x update-new.sh && ./update-new.sh
```

**Windows** (Command Prompt, in the instance folder):

```
git fetch origin && git show origin/main:update.bat > update-new.bat && update-new.bat
```

Afterwards delete the `update-new` file and use the normal `update` script
again. Only needed once.

## What's tracked vs. not

Tracked (synced to everyone): `mods/`, `shaderpacks/`, `mmc-pack.json`
(loader/MC version), and the parts of `config/` that change how the game
plays.

Not tracked (stays local/personal): saves, screenshots, logs, minimap data,
`instance.cfg` (Java path/RAM/playtime), `options.txt` (keybinds/video
settings), Distant Horizons world cache, and the client config the game
rewrites on every launch: video/shader settings (`sodium-*`, `iris*`,
shaderpack `.zip.txt` settings), HUD layout (`jade/`), and chat ping words
(`sounds/chat.json`).

Those last ones used to be tracked, which meant just playing the game left
your folder "modified" and made updates fail. They now ship as `.example`
templates that the setup and update scripts copy into place if the real file
is missing, so a fresh install still starts with shaders on.
