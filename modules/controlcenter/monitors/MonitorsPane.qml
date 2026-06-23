pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Display")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            first: true
            text: qsTr("Identify displays")
            subtext: qsTr("Show monitor IDs on each screen")
            checked: Monitors.identifying
            onToggled: Monitors.toggleIdentification()
        }

        ItemList {
            id: monitorList

            Layout.fillWidth: true
            showList: true
            last: true
            placeholderIcon: "monitor"
            placeholderText: qsTr("No displays connected")

            model: ScriptModel {
                values: Hyprctl.monitors
            }

            delegate: StyledRect {
                id: listItem

                required property var modelData
                required property int index

                anchors.left: monitorList.list.contentItem.left
                anchors.right: monitorList.list.contentItem.right
                implicitHeight: itemRow.implicitHeight + itemRow.anchors.margins * 2
                radius: Tokens.rounding.extraSmall
                color: "transparent"

                StateLayer {
                    onClicked: {
                        nState.selectedMonitor = listItem.modelData;
                        nState.openSubPage(1); // Open detail sub-page
                    }
                }

                RowLayout {
                    id: itemRow

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.medium
                    anchors.leftMargin: Tokens.padding.largeIncreased
                    anchors.rightMargin: Tokens.padding.largeIncreased
                    spacing: Tokens.spacing.medium

                    // Monitor icon badge
                    StyledRect {
                        implicitWidth: implicitHeight
                        implicitHeight: monIcon.implicitHeight + Tokens.padding.small * 2
                        radius: Tokens.rounding.full
                        color: listItem.modelData?.focused ? Colours.palette.m3primary : Colours.palette.m3secondaryContainer

                        MaterialIcon {
                            id: monIcon
                            anchors.centerIn: parent
                            text: "monitor"
                            fontStyle: Tokens.font.icon.medium
                            fill: listItem.modelData?.focused ? 1 : 0
                            color: listItem.modelData?.focused
                                ? Colours.palette.m3onPrimary
                                : Colours.palette.m3onSecondaryContainer
                        }
                    }

                    // Name + resolution
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            text: listItem.modelData?.name ?? ""
                            font.pointSize: Tokens.font.body.small.pointSize
                            font.weight: listItem.modelData?.focused ? Font.Medium : Font.Normal
                        }

                        StyledText {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            font: Tokens.font.label.small
                            color: Colours.palette.m3outline
                            text: {
                                const m = listItem.modelData;
                                if (!m || !m.width || !m.height) return qsTr("Unavailable");
                                const rr = m.refreshRate ?? 0;
                                return qsTr("%1×%2 @ %3 Hz").arg(m.width).arg(m.height).arg(rr.toFixed(0));
                            }
                        }
                    }

                    // Settings button
                    IconButton {
                        icon: "settings"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        inactiveOnColour: listItem.modelData?.focused ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        label.fill: 0
                        onClicked: {
                            nState.selectedMonitor = listItem.modelData;
                            nState.openSubPage(1); // Open detail sub-page
                        }
                    }
                }
            }
        }
    }
}
