pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property list<var> monitors: []

    function update(): void {
        proc.running = true;
    }

    readonly property Process proc: Process {
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(text);
                } catch (e) {
                    console.error("Hyprctl: failed to parse monitors JSON", e);
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.update()
    }

    Component.onCompleted: update()

    // Refresh when Hyprland reports changes
    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name.includes("mon")) {
                root.update();
            }
        }
    }
}
