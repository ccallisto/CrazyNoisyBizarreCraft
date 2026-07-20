#!/usr/bin/env bash
# Updates the pack from git.
#
#   ./update.sh              double-clicked by a player, chatty, waits for a key
#   ./update.sh --prelaunch  run by PrismLauncher before the game starts
#
# In --prelaunch mode this script must NEVER exit non-zero. Prism aborts the
# launch on any non-zero exit from a pre-launch command, so a flaky network
# would otherwise leave someone unable to start the game at all. Being one
# update behind is a far smaller problem than being unable to play.

cd "$(dirname "$0")" || exit 0

PRELAUNCH=0
if [ "$1" = "--prelaunch" ]; then
    PRELAUNCH=1
fi

# Client config that belongs to you and your machine rather than to the pack:
# video settings, shader choice, HUD layout, chat ping words. The game rewrites
# these on every launch, so they are not tracked in git (see .gitignore). They
# are copied aside here and put back afterwards, so updating never costs you
# your settings.
PERSONAL="minecraft/config/iris.properties
minecraft/config/iris-excluded.json
minecraft/config/sodium-options.json
minecraft/config/sodium-extra-options.json
minecraft/config/sodium-extra.properties
minecraft/config/sodium-fingerprint.json
minecraft/config/sodium-mixins.properties
minecraft/config/sodium-shadowy-path-blocks-options.json
minecraft/config/fabric/indigo-renderer.properties
minecraft/config/euphoria_patcher/.data.json
minecraft/config/sounds/chat.json
minecraft/config/constructionwand-client.toml
minecraft/config/jade"

BACKUP=".update-personal-backup"

restore_personal() {
    if [ -d "$BACKUP/minecraft" ]; then
        cp -a "$BACKUP/minecraft/." minecraft/
    fi
    rm -rf "$BACKUP"
}

# Fill in any file the pack ships a default for but that does not exist yet.
seed_defaults() {
    find minecraft -name '*.example' -type f 2>/dev/null | while IFS= read -r ex; do
        target="${ex%.example}"
        if [ ! -e "$target" ]; then
            mkdir -p "$(dirname "$target")"
            cp "$ex" "$target"
        fi
    done
    if [ ! -f instance.cfg ] && [ -f instance.cfg.example ]; then
        cp instance.cfg.example instance.cfg
    fi
}

# Give up on updating, but leave the instance in a working state either way.
give_up() {
    restore_personal
    seed_defaults
    echo ""
    echo "$1"
    if [ "$PRELAUNCH" = "1" ]; then
        echo "Starting the game with the pack you already have."
        exit 0
    fi
    echo "$2"
    exit 1
}

echo "=== Updating CrazyNoisyBizarreCraft ==="
echo ""

if ! command -v git >/dev/null 2>&1; then
    give_up "git is not installed." "Run setup.sh first."
fi

rm -rf "$BACKUP"

while IFS= read -r f; do
    [ -e "$f" ] || continue
    mkdir -p "$BACKUP/$(dirname "$f")"
    cp -a "$f" "$BACKUP/$(dirname "$f")/"
done <<< "$PERSONAL"

for s in minecraft/shaderpacks/*.zip.txt; do
    [ -e "$s" ] || continue
    mkdir -p "$BACKUP/minecraft/shaderpacks"
    cp -a "$s" "$BACKUP/minecraft/shaderpacks/"
done

# Drop local edits to those same paths so the update can never be blocked by
# them. Safe, because the copies taken above are restored on every exit path.
while IFS= read -r f; do
    git checkout -- "$f" 2>/dev/null || true
done <<< "$PERSONAL"
git checkout -- minecraft/shaderpacks 2>/dev/null || true

if ! git fetch origin; then
    give_up "Couldn't reach GitHub to check for updates." \
            "Check your internet connection and try again."
fi

# merge rather than pull: "git pull --ff-only" still errors out for anyone who
# has pull.rebase=true in their global git config, which some people do.
if ! git merge --ff-only origin/main; then
    give_up "Update didn't apply cleanly (something local conflicts with it)." \
            "Ask for help before changing anything else, don't run git commands blind."
fi

# Settings go back before anything else that can fail, so a later problem can
# never strand them in the backup folder.
restore_personal

if ! git lfs pull; then
    echo ""
    echo "Warning: couldn't download some large mod files."
    echo "The rest of the update applied and your settings are intact."
    echo "Run this again later to finish fetching them."
fi

seed_defaults

# Wire up automatic updating on launch, unless the player has set their own
# pre-launch command. Only done in the interactive path: Prism reads
# instance.cfg while launching, so --prelaunch must not rewrite it mid-launch.
if [ "$PRELAUNCH" = "0" ] && [ -f instance.cfg ]; then
    if ! grep -q '^PreLaunchCommand=..*' instance.cfg; then
        set_cfg() {
            tmp="$(mktemp)"
            found=0
            while IFS= read -r line || [ -n "$line" ]; do
                case "$line" in
                    "$1="*) printf '%s=%s\n' "$1" "$2"; found=1 ;;
                    *) printf '%s\n' "$line" ;;
                esac
            done < instance.cfg > "$tmp"
            if [ "$found" = "0" ]; then
                printf '%s=%s\n' "$1" "$2" >> "$tmp"
            fi
            mv "$tmp" instance.cfg
        }
        set_cfg OverrideCommands true
        set_cfg PreLaunchCommand '$INST_DIR/update.sh --prelaunch'
        set_cfg OverrideConsole true
        set_cfg LogPrePostOutput true
        set_cfg ShowConsole false
        set_cfg ShowConsoleOnError true
        echo ""
        echo "Automatic updates are now on: the pack refreshes itself each time"
        echo "you press Play, so you shouldn't need to run this by hand again."
    fi
fi

echo ""
echo "Pack updated! Restart PrismLauncher if it was already open."

# Only wait for a keypress when a person is watching. Under Prism there is no
# terminal, and pausing here would hang the launch forever.
if [ "$PRELAUNCH" = "0" ] && [ -t 0 ]; then
    read -rp "Press Enter to close..."
fi
exit 0
