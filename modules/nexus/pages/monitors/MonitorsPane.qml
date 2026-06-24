pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.modules.nexus.common
import qs.services

PageBase {
    id: root

    title: qsTr("Displays")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Identify displays")
            font: Tokens.font.body.medium
            horizontalPadding: Tokens.padding.largeIncreased
            checked: Monitors.identifying
            onToggled: Monitors.toggleIdentification()
        }

        Repeater {
            model: Hyprctl.monitors

            delegate: ConnectedRect {
                required property var modelData
                required property int index

                Layout.fillWidth: true
                implicitHeight: itemLayout.implicitHeight + itemLayout.anchors.margins * 2
                first: false
                last: index === Hyprctl.monitors.length - 1

                StateLayer {
                    onClicked: {
                        root.nState.selectedMonitor = modelData;
                        root.nState.openSubPage(1);
                    }
                }

                RowLayout {
                    id: itemLayout
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.medium
                    anchors.leftMargin: Tokens.padding.largeIncreased
                    anchors.rightMargin: Tokens.padding.largeIncreased
                    spacing: Tokens.spacing.medium

                    MaterialIcon {
                        text: "monitor"
                        fontStyle: Tokens.font.icon.medium
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.name
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: {
                                const m = modelData;
                                if (!m || !m.width || !m.height) return qsTr("Unavailable");
                                const rr = m.refreshRate ?? 0;
                                return qsTr("%1×%2 @ %3 Hz").arg(m.width).arg(m.height).arg(rr.toFixed(0));
                            }
                            color: Colours.palette.m3outline
                            font: Tokens.font.label.small
                            elide: Text.ElideRight
                        }
                    }

                    MaterialIcon {
                        text: (modelData.focused ?? false) ? "settings" : "chevron_right"
                        color: (modelData.focused ?? false) ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        fontStyle: Tokens.font.icon.medium
                    }
                }
            }
        }
    }
}
