pragma Singleton

import qs.services
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool identifying: false

    // Auto-dismiss identify overlay after 5 seconds
    Timer {
        id: identifyTimer
        interval: 5000
        onTriggered: root.identifying = false
    }

    function toggleIdentification(): void {
        identifying = !identifying;
        if (identifying)
            identifyTimer.restart();
        else
            identifyTimer.stop();
    }

    function stopIdentification(): void {
        identifying = false;
        identifyTimer.stop();
    }

    // Safely iterate UntypedObjectModel — .find() doesn't work on it
    function findMonitorByName(name: string): var {
        for (let i = 0; i < Hypr.monitors.length; i++) {
            if (Hypr.monitors[i].name === name)
                return Hypr.monitors[i];
        }
        return null;
    }

    function findMonitorById(id: int): var {
        for (let i = 0; i < Hypr.monitors.length; i++) {
            if (Hypr.monitors[i].id === id)
                return Hypr.monitors[i];
        }
        return null;
    }

    // Build the monitor string Hyprland expects:
    // NAME,WIDTHxHEIGHT@RATE,XxY,SCALE[,transform,N]
    function monitorStr(mon: var, overrideScale: real, overrideTransform: int): string {
        const scale     = overrideScale     >= 0 ? overrideScale     : (mon.scale     || 1);
        const transform = overrideTransform >= 0 ? overrideTransform : (mon.transform || 0);
        const rr = (mon.refreshRate || 60).toFixed(3);
        let s = `${mon.name},${mon.width}x${mon.height}@${rr},${mon.x}x${mon.y},${scale}`;
        if (transform !== 0)
            s += `,transform,${transform}`;
        return s;
    }

    // Use batchMessage (hyprctl keyword), NOT dispatch (hyprctl dispatch)
    // "keyword" is a config command, not a dispatcher action.
    function sendKeyword(monStr: string): void {
        Hypr.extras.batchMessage([`keyword monitor ${monStr}`]);
    }

    function arrange(monitorName: string, pos: string, relativeToId: int): void {
        const target = findMonitorById(relativeToId);
        const moving = findMonitorByName(monitorName);
        if (!target || !moving) return;

        let x = target.x;
        let y = target.y;

        const targetW = Math.round(target.width  / (target.scale || 1));
        const targetH = Math.round(target.height / (target.scale || 1));
        const movingW = Math.round(moving.width  / (moving.scale || 1));
        const movingH = Math.round(moving.height / (moving.scale || 1));

        if      (pos === "left")   x -= movingW;
        else if (pos === "right")  x += targetW;
        else if (pos === "top")    y -= movingH;
        else if (pos === "bottom") y += targetH;

        sendKeyword(monitorStr(moving, moving.scale || 1, moving.transform || 0)
            .replace(`${moving.x}x${moving.y}`, `${Math.round(x)}x${Math.round(y)}`));
    }

    function rotate(monitorName: string, angle: int): void {
        const mon = findMonitorByName(monitorName);
        if (!mon) return;

        let transform = 0;
        if      (angle === 90)  transform = 1;
        else if (angle === 180) transform = 2;
        else if (angle === 270) transform = 3;

        sendKeyword(monitorStr(mon, mon.scale || 1, transform));
    }

    function setScale(monitorName: string, scale: real): void {
        const mon = findMonitorByName(monitorName);
        if (!mon) return;
        const s = Math.max(0.5, Math.min(3.0, scale));
        sendKeyword(monitorStr(mon, s, mon.transform || 0));
    }
}
