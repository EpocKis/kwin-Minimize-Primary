#!/bin/bash
# minimize-primary.sh
# Toggles minimize/restore of all windows on the primary monitor.
# Works on Wayland (KDE Plasma 6) via KWin scripting + DBus.
#
# Dependencies: kscreen-doctor (kscreen), qdbus6 (qt6-tools)
# Install: sudo pacman -S kscreen qt6-tools

GEOMETRY=$(kscreen-doctor -o | awk '/priority 1/{found=1} found && /Geometry:/{match($0, /[0-9]+,[0-9]+ [0-9]+x[0-9]+/); print substr($0, RSTART, RLENGTH); exit}')
SX=$(echo $GEOMETRY | grep -oP '^\d+')
SY=$(echo $GEOMETRY | grep -oP '(?<=,)\d+(?= )')
SW=$(echo $GEOMETRY | grep -oP '(?<= )\d+(?=x)')
SH=$(echo $GEOMETRY | grep -oP '(?<=x)\d+$')

SCRIPT_FILE=$(mktemp /tmp/kwin_minimize_XXXXXX.js)

cat > "$SCRIPT_FILE" << JSEOF
(function() {
    var sx = $SX, sy = $SY, sw = $SW, sh = $SH;
    var windows = workspace.windowList();
    var onScreen = [];
    for (var i = 0; i < windows.length; i++) {
        var w = windows[i];
        if (!w.minimizable) continue;
        var cx = w.x + w.width / 2;
        var cy = w.y + w.height / 2;
        if (cx >= sx && cx < sx + sw && cy >= sy && cy < sy + sh) {
            onScreen.push(w);
        }
    }
    var anyUnminimized = onScreen.some(function(w) { return !w.minimized; });
    for (var i = 0; i < onScreen.length; i++) {
        onScreen[i].minimized = anyUnminimized;
    }
})();
JSEOF

PLUGIN="min_primary_$$"
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$SCRIPT_FILE" "$PLUGIN"
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start
sleep 0.3
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$PLUGIN"
rm -f "$SCRIPT_FILE"
