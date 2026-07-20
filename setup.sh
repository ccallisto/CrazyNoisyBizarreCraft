#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/ccallisto/CrazyNoisyBizarreCraft.git"
INSTANCE_NAME="CrazyNoisyBizarreCraft"

echo "=== CrazyNoisyBizarreCraft pack setup ==="
echo ""

if ! command -v git >/dev/null 2>&1; then
    echo "git is not installed. Install it first, then run this script again:"
    echo "  macOS:  xcode-select --install    (or: brew install git)"
    echo "  Linux:  sudo apt install git      (or: sudo dnf install git)"
    exit 1
fi

if ! git lfs version >/dev/null 2>&1; then
    echo "git-lfs is not installed. Install it first, then run this script again:"
    echo "  macOS:  brew install git-lfs"
    echo "  Linux:  sudo apt install git-lfs  (or: sudo dnf install git-lfs)"
    exit 1
fi

CANDIDATES=(
    "$HOME/Library/Application Support/PrismLauncher/instances"
    "$HOME/.local/share/PrismLauncher/instances"
    "$HOME/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances"
)

TARGET_DIR=""
for c in "${CANDIDATES[@]}"; do
    if [ -d "$c" ]; then
        TARGET_DIR="$c"
        break
    fi
done

if [ -z "$TARGET_DIR" ]; then
    echo "Couldn't auto-find your PrismLauncher instances folder."
    echo "(In PrismLauncher: Settings -> the folder icon next to 'Instance Dir' shows the path.)"
    read -rp "Paste the full path to it: " TARGET_DIR
fi

DEST="$TARGET_DIR/$INSTANCE_NAME"

if [ -d "$DEST" ]; then
    echo ""
    echo "A folder already exists at: $DEST"
    echo "If you're trying to get updates, run update.sh inside that folder instead."
    exit 1
fi

echo ""
echo "Cloning pack into: $DEST"
git clone "$REPO_URL" "$DEST"

cd "$DEST"
git lfs pull

# update.sh already knows how to seed the pack's default client config and to
# switch on automatic updates, so reuse it rather than repeating the logic.
# Redirecting stdin keeps it from waiting for a keypress here.
./update.sh </dev/null

echo ""
echo "Done! Open PrismLauncher — the instance should appear automatically."
echo "If it doesn't, restart PrismLauncher."
