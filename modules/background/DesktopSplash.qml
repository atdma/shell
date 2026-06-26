pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property real clockScale
    required property bool useLightSet
    required property color safePrimary
    required property color safeSecondary

    property string splashText: "Hyprland"
    readonly property var chars: splashText.split("")

    implicitWidth: wavyRow.implicitWidth
    implicitHeight: wavyRow.implicitHeight + 16 * root.clockScale

    Component.onCompleted: splashProc.running = true

    Process {
        id: splashProc

        command: ["hyprctl", "splash"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") {
                    root.splashText = text.trim();
                }
            }
        }
    }

    Row {
        id: wavyRow

        property real animOffset: 0

        anchors.centerIn: parent
        spacing: 1 * root.clockScale

        Component.onCompleted: waveAnim.start()

        NumberAnimation {
            id: waveAnim

            target: wavyRow
            property: "animOffset"
            from: 0
            to: 2 * Math.PI
            duration: 3000
            loops: Animation.Infinite
        }

        Repeater {
            model: root.chars

            delegate: StyledText {
                required property string modelData
                required property int index

                text: modelData
                font: Tokens.font.body.builders.medium.weight(Font.Medium).size(Tokens.font.body.medium.pointSize * 1.15 * root.clockScale).build()
                color: root.useLightSet ? Colours.palette.m3primary : Colours.palette.m3onSurface
                opacity: 0.75

                y: Math.sin(wavyRow.animOffset - index * 0.25) * (4 * root.clockScale)
            }
        }
    }
}
