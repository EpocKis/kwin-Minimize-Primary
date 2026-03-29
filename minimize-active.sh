#!/bin/bash
# minimize-primary.sh
# Toggles minimize/restore of all windows on the screen currently under the mouse cursor.
# Works on Wayland (KDE Plasma 6) via KWin scripting + DBus.
#
# Dependency: qdbus6 (qt6-tools)

set -euo pipefail

SCRIPT_FILE=$(mktemp /tmp/kwin_minimize_XXXXXX.js)
PLUGIN="min_current_$$"

cleanup() {
    qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$PLUGIN" >/dev/null 2>&1 || true
    rm -f "$SCRIPT_FILE"
}
trap cleanup EXIT

cat > "$SCRIPT_FILE" <<'JSEOF'
(function() {
    function isUsableWindow(w) {
        if (!w) return false;
        if (!w.minimizable) return false;

        // Skip desktop/panel/plasma/system-ish windows
        if (w.desktopWindow) return false;
        if (w.dock) return false;
        if (w.splash) return false;
        if (w.utility) return false;
        if (w.notification) return false;
        if (w.onScreenDisplay) return false;
        if (w.criticalNotification) return false;
        if (w.appletPopup) return false;
        if (w.popupWindow) return false;
        if (w.specialWindow) return false;
        if (w.skipTaskbar) return false;
        if (w.resourceClass === "plasmashell") return false;

        return true;
    }

    function rectContains(rect, x, y) {
        return x >= rect.x &&
               y >= rect.y &&
               x < rect.x + rect.width &&
               y < rect.y + rect.height;
    }

    var cursor = workspace.cursorPos;
    var screen = workspace.screenAt(cursor);

    if (!screen) {
        return;
    }

    var sg = screen.geometry;
    var windows = workspace.windowList();
    var onScreen = [];

    for (var i = 0; i < windows.length; i++) {
        var w = windows[i];
        if (!isUsableWindow(w)) continue;

        var g = w.frameGeometry ? w.frameGeometry : { x: w.x, y: w.y, width: w.width, height: w.height };
        var cx = g.x + g.width / 2;
        var cy = g.y + g.height / 2;

        if (rectContains(sg, cx, cy)) {
            onScreen.push(w);
        }
    }

    if (onScreen.length === 0) {
        return;
    }

    var anyUnminimized = false;
    for (var j = 0; j < onScreen.length; j++) {
        if (!onScreen[j].minimized) {
            anyUnminimized = true;
            break;
        }
    }

    for (var k = 0; k < onScreen.length; k++) {
        onScreen[k].minimized = anyUnminimized;
    }
})();
JSEOF

qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$SCRIPT_FILE" "$PLUGIN" >/dev/null
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null
sleep 0.3
