pragma Singleton

import QtQuick

Item {
    id: root

    // Default Caelestia color scheme (fallback)
    property QtObject palette: QtObject {
        property color m3background: "#191114"
        property color m3onBackground: "#efdfe2"
        property color m3onSurface: "#efdfe2"
        property color m3primary: "#ffb0ca"
        property color m3onPrimary: "#541d34"
        property color m3surfaceContainer: "#261d20"
        property color m3onSurfaceVariant: "#d5c2c6"
        property color m3surface: "#191114"
    }

    // Get scheme path from C++ context property, with fallback
    property string schemePath: {
        if (typeof schemeFilePath !== "undefined") {
            return schemeFilePath;
        }
        // Default XDG location fallback
        const home = Qt.application.arguments.includes("--home") 
            ? Qt.application.arguments[Qt.application.arguments.indexOf("--home") + 1]
            : null;
        
        if (home) {
            return `${home}/scheme.json`;
        }
        
        // Default XDG location
        return `${Qt.application.arguments[0].substring(0, Qt.application.arguments[0].lastIndexOf("/"))}/../../.local/state/caelestia/scheme.json`;
    }

    function loadScheme(): void {
        try {
            const xhr = new XMLHttpRequest();
            xhr.open("GET", "file://" + schemePath, false);
            xhr.send();
            
            if (xhr.status === 200 || xhr.status === 0) {
                const scheme = JSON.parse(xhr.responseText);
                applyScheme(scheme);
            }
        } catch (e) {
            // Silently use defaults if file doesn't exist or can't be read
        }
    }

    function applyScheme(scheme: var): void {
        for (const [name, colour] of Object.entries(scheme.colours || {})) {
            const propName = name.startsWith("term") ? name : `m3${name}`;
            if (palette.hasOwnProperty(propName)) {
                palette[propName] = `#${colour}`;
            }
        }
    }

    Timer {
        id: fileWatcher
        interval: 500
        running: true
        repeat: true
        onTriggered: root.loadScheme()
    }

    Component.onCompleted: {
        loadScheme();
    }
}
