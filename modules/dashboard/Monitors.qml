import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    spacing: Appearance.spacing.large

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: Appearance.padding.normal

        StyledText {
            text: qsTr("Monitors")
            font.pointSize: Appearance.font.size.extraLarge
            Layout.fillWidth: true
        }

        IconTextButton {
            icon: "info"
            text: qsTr("Identify")
            toggle: true
            checked: Monitors.identifying
            onClicked: Monitors.toggleIdentification()
        }
    }

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentHeight: monitorsLayout.implicitHeight
        clip: true

        ColumnLayout {
            id: monitorsLayout
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.normal

            Repeater {
                model: Hyprctl.monitors

                delegate: StyledRect {
                    id: monitorDelegate
                    Layout.fillWidth: true
                    implicitHeight: monitorContent.implicitHeight + Appearance.padding.large * 2
                    color: Colours.tPalette.m3surfaceContainerHigh
                    radius: Appearance.rounding.large

                    readonly property var mon: modelData
                    readonly property var brightnessMon: Brightness.getMonitor(mon.name)

                    ColumnLayout {
                        id: monitorContent
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.medium

                        RowLayout {
                            Layout.fillWidth: true
                            MaterialIcon {
                                text: "monitor"
                                color: Colours.palette.m3primary
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                StyledText {
                                    text: `${mon.name} - ${mon.make} ${mon.model}`
                                    font.pointSize: Appearance.font.size.large
                                    Layout.fillWidth: true
                                }
                                StyledText {
                                    text: `${mon.width}x${mon.height}@${(mon.refreshRate ?? 0).toFixed(2)}Hz`
                                    color: Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.small
                                }
                            }
                            StyledText {
                                text: `ID: ${mon.id}`
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }

                        // Brightness
                        RowLayout {
                            Layout.fillWidth: true
                            visible: !!brightnessMon

                            MaterialIcon {
                                text: "brightness_medium"
                                font.pointSize: Appearance.font.size.normal
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                value: brightnessMon?.brightness ?? 0
                                onMoved: if (brightnessMon) brightnessMon.setBrightness(value)
                            }

                            StyledText {
                                text: `${Math.round((brightnessMon?.brightness ?? 0) * 100)}%`
                                Layout.preferredWidth: 40
                            }
                        }

                        // Scaling
                        RowLayout {
                            Layout.fillWidth: true

                            MaterialIcon {
                                text: "zoom_in"
                                font.pointSize: Appearance.font.size.normal
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                from: 0.5
                                to: 3.0
                                value: mon.scale
                                onMoved: Monitors.setScale(mon.name, value)
                            }

                            StyledText {
                                text: `${mon.scale.toFixed(2)}x`
                                Layout.preferredWidth: 40
                            }
                        }

                        // Refresh Rate
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            StyledText {
                                text: qsTr("Refresh Rate")
                                Layout.fillWidth: true
                            }

                            CustomSpinBox {
                                id: rrSelector
                                min: 10
                                max: 1000
                                step: 1
                                value: mon.refreshRate
                                onValueModified: val => Monitors.setRefreshRate(mon.name, val)
                            }
                        }

                        // Rotation
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            StyledText {
                                text: qsTr("Rotation")
                                Layout.fillWidth: true
                            }

                            Repeater {
                                model: [
                                    { label: "0°", val: 0, icon: "screen_rotation" },
                                    { label: "90°", val: 1, icon: "screen_rotation" },
                                    { label: "180°", val: 2, icon: "screen_rotation" },
                                    { label: "270°", val: 3, icon: "screen_rotation" }
                                ]

                                delegate: IconButton {
                                    icon: modelData.icon
                                    toggle: true
                                    checked: mon.transform === modelData.val
                                    onClicked: Monitors.rotate(mon.name, modelData.val * 90)
                                }
                            }
                        }

                        // Arrangement
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            StyledText {
                                text: qsTr("Position relative to:")
                                Layout.fillWidth: true
                            }

                            CustomSpinBox {
                                id: targetMonSelector
                                min: 0
                                max: Math.max(0, (Hyprctl.monitors?.length ?? 1) - 1)
                                value: 0
                            }

                            IconButton {
                                icon: "arrow_back"
                                onClicked: Monitors.arrange(mon.name, "left", targetMonSelector.value)
                            }
                            IconButton {
                                icon: "arrow_forward"
                                onClicked: Monitors.arrange(mon.name, "right", targetMonSelector.value)
                            }
                            IconButton {
                                icon: "arrow_upward"
                                onClicked: Monitors.arrange(mon.name, "top", targetMonSelector.value)
                            }
                            IconButton {
                                icon: "arrow_downward"
                                onClicked: Monitors.arrange(mon.name, "bottom", targetMonSelector.value)
                            }
                        }
                    }
                }
            }
        }
    }
}
