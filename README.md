# kwin-minimize-active

Toggles minimize/restore of all windows on the **active monitor only** in KDE Plasma 6 on Wayland.

Think of it as `Meta+D` (show desktop) but scoped to one screen — useful on multi-monitor setups where you want to clear your active screen without touching your other displays.

---

## Why does this exist?

KDE's built-in `Meta+D` minimizes windows on all screens. There is no native per-monitor equivalent. Tools like `wmctrl` and `xdotool` that handled this on X11 do not work on Wayland.

This script uses **KWin's DBus scripting API**, which is the proper Wayland-native approach.

---

## Requirements

- KDE Plasma 6
- Wayland session
- `kscreen` (for `kscreen-doctor`)
- `qt6-tools` (for `qdbus6`)

On Arch / CachyOS / Manjaro:
```bash
sudo pacman -S kscreen qt6-tools
```

---

## Install

```bash
git clone https://github.com/EpocKis/kwin-minimize-active
cd kwin-minimize-active
chmod +x install.sh
./install.sh
```

Or manually:
```bash
cp minimize-active.sh ~/.local/bin/
chmod +x ~/.local/bin/minimize-active.sh
```

Then in **System Settings → Shortcuts → Add New → Command or Script**:
- Command: `/home/YOUR_USERNAME/.local/bin/minimize-active.sh`
- Shortcut: `Meta+Shift+D`

---

## How it works

1. Reads the primary monitor's geometry at runtime via `kscreen-doctor` (so it adapts automatically if you rearrange monitors or change resolution)
2. Loads a small JavaScript snippet into KWin via DBus
3. The script checks each window's center point against the primary screen bounds
4. If any windows are visible → minimizes all of them
5. If all are minimized → restores all of them

---

## Tested on

- CachyOS (Arch-based), KDE Plasma 6, Wayland

---

## License

MIT
