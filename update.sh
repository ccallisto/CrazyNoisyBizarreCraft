#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== Updating CrazyNoisyBizarreCraft ==="
echo ""

if ! command -v git >/dev/null 2>&1; then
    echo "git is not installed. Run setup.sh first."
    exit 1
fi

git fetch origin

if ! git pull --ff-only origin main; then
    echo ""
    echo "Update didn't apply cleanly (local changes conflict with the update)."
    echo "Ask for help before changing anything else — don't run git commands blind."
    exit 1
fi

git lfs pull

if [ ! -f instance.cfg ]; then
    cp instance.cfg.example instance.cfg
fi

echo ""
echo "Pack updated! Restart PrismLauncher if it was already open."
read -rp "Press Enter to close..."
