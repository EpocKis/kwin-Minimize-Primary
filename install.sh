#!/bin/bash
# install.sh — installs minimize-primary and sets up Meta+Shift+D shortcut

set -e

echo "=== minimize-primary installer ==="

# Check dependencies
MISSING=()
command -v kscreen-doctor &>/dev/null || MISSING+=("kscreen")
command -v qdbus6 &>/dev/null || MISSING+=("qt6-tools")

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Installing missing dependencies: ${MISSING[*]}"
    sudo pacman -S --needed "${MISSING[@]}"
fi

# Install script
mkdir -p ~/.local/bin
cp minimize-primary.sh ~/.local/bin/minimize-primary.sh
chmod +x ~/.local/bin/minimize-primary.sh
echo "✓ Script installed to ~/.local/bin/minimize-primary.sh"

# Register KDE shortcut via kglobalaccel / kwriteconfig
KSHORTCUTS="$HOME/.config/kglobalshortcutsrc"

if ! grep -q 'minimize-primary' "$KSHORTCUTS" 2>/dev/null; then
    kwriteconfig6 --file kglobalshortcutsrc \
        --group "minimize-primary.sh" \
        --key "_k_friendly_name" "Minimize primary screen"
    kwriteconfig6 --file kglobalshortcutsrc \
        --group "minimize-primary.sh" \
        --key "minimize-primary" \
        "Meta+Shift+D,none,Minimize primary screen"
    echo "✓ Shortcut Meta+Shift+D registered"
    echo "  Note: You may need to set it manually in System Settings → Shortcuts"
    echo "  if it does not appear automatically."
else
    echo "✓ Shortcut already registered"
fi

echo ""
echo "Done! Test it with:"
echo "  ~/.local/bin/minimize-primary.sh"
echo ""
echo "Or bind it manually in:"
echo "  System Settings → Shortcuts → Add New → Command or Script"
echo "  Command: /home/$USER/.local/bin/minimize-primary.sh"
echo "  Shortcut: Meta+Shift+D"
