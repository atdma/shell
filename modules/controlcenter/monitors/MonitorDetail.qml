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
import "../components"

PageBase {
    id: root

    readonly property var mon: nState.selectedMonitor
    readonly property var brightnessMon: mon ? Brightness.getMonitor(mon.name) : null

    onMonChanged: {
        if (!mon) {
            nState.closeSubPage();
        }
    }

    title: mon?.name ?? qsTr("Monitor")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.medium

        // ── Brightness ───────────────────────────────────────
        SliderRow {
            first: true
            last: true
            visible: root.brightnessMon !== null && root.brightnessMon !== undefined
            icon: (root.brightnessMon?.brightness ?? 0) > 0.5 ? "brightness_high" : "brightness_low"
            label: qsTr("Brightness")
            valueLabel: Math.round((root.brightnessMon?.brightness ?? 0) * 100) + "%"
            value: root.brightnessMon?.brightness ?? 0
            onMoved: v => {
                if (root.brightnessMon)
                    root.brightnessMon.setBrightness(v);
            }
        }

        // ── Refresh rate ─────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            SectionHeader {
                text: qsTr("Refresh rate")
            }

            SectionContainer {
                contentSpacing: Tokens.spacing.medium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Custom rate")
                        font: Tokens.font.body.small
                    }

                    CustomSpinBox {
                        min: 10
                        max: 1000
                        step: 0.01
                        value: root.mon?.refreshRate ?? 60
                        onValueModified: value => {
                            if (root.mon)
                                Monitors.setRefreshRate(root.mon.name, value);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    Repeater {
                        model: [30, 50, 59, 60]

                        delegate: StyledRect {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            implicitWidth: rateChipLabel.implicitWidth + Tokens.padding.large * 2
                            implicitHeight: rateChipLabel.implicitHeight + Tokens.padding.medium * 2
                            radius: Tokens.rounding.full

                            readonly property bool isActive: Math.abs((root.mon?.refreshRate ?? 0) - modelData) < 0.1

                            color: isActive ? Colours.palette.m3secondaryContainer : Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

                            StateLayer {
                                color: parent.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                                function onClicked(): void {
                                    if (root.mon)
                                        Monitors.setRefreshRate(root.mon.name, modelData);
                                }
                            }

                            StyledText {
                                id: rateChipLabel
                                anchors.centerIn: parent
                                text: qsTr("%1 Hz").arg(modelData)
                                font: Tokens.font.body.small
                                color: parent.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                            }

                            Behavior on color {
                                CAnim {}
                            }
                        }
                    }
                }
            }
        }

        // ── Rotation ─────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            SectionHeader {
                text: qsTr("Rotation")
            }

            SectionContainer {
                contentSpacing: Tokens.spacing.small

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    Repeater {
                        model: [
                            {
                                label: qsTr("0°"),
                                transform: 0,
                                angle: 0
                            },
                            {
                                label: qsTr("90°"),
                                transform: 1,
                                angle: 90
                            },
                            {
                                label: qsTr("180°"),
                                transform: 2,
                                angle: 180
                            },
                            {
                                label: qsTr("270°"),
                                transform: 3,
                                angle: 270
                            }
                        ]

                        delegate: RotationChip {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            chipLabel: modelData.label
                            chipAngle: modelData.angle
                            isActive: (root.mon?.transform ?? 0) === modelData.transform
                            onClicked: {
                                if (root.mon)
                                    Monitors.rotate(root.mon.name, modelData.angle);
                            }
                        }
                    }
                }
            }
        }

        // ── Scale ────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            SectionHeader {
                text: qsTr("Scale")
            }

            SectionContainer {
                contentSpacing: Tokens.spacing.medium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    MaterialIcon {
                        text: "zoom_in"
                        fontStyle: Tokens.font.icon.medium
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    StyledSlider {
                        id: scaleSlider
                        Layout.fillWidth: true
                        implicitHeight: Tokens.padding.medium * 3
                        from: 0.5
                        to: 3.0
                        stepSize: 0.25
                        value: root.mon?.scale ?? 1

                        onMoved: scaleTimer.restart()

                        Timer {
                            id: scaleTimer
                            interval: 350
                            repeat: false
                            onTriggered: {
                                if (root.mon)
                                    Monitors.setScale(root.mon.name, scaleSlider.value);
                            }
                        }
                    }

                    StyledText {
                        text: qsTr("×%1").arg((root.mon?.scale ?? 1).toFixed(2))
                        font: Tokens.font.body.small
                        color: Colours.palette.m3outline
                    }
                }

                // Quick-pick chips: 1×, 1.25×, 1.5×, 2×
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    Repeater {
                        model: [1.0, 1.25, 1.5, 2.0]

                        delegate: StyledRect {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            implicitWidth: scaleChipLabel.implicitWidth + Tokens.padding.large * 2
                            implicitHeight: scaleChipLabel.implicitHeight + Tokens.padding.medium * 2
                            radius: Tokens.rounding.full

                            readonly property bool isActive: Math.abs((root.mon?.scale ?? 1) - modelData) < 0.01

                            color: isActive ? Colours.palette.m3secondaryContainer : Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

                            StateLayer {
                                color: parent.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                                function onClicked(): void {
                                    if (root.mon)
                                        Monitors.setScale(root.mon.name, modelData);
                                }
                            }

                            StyledText {
                                id: scaleChipLabel
                                anchors.centerIn: parent
                                text: qsTr("×%1").arg(modelData.toFixed(2))
                                font: Tokens.font.body.small
                                color: parent.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                            }

                            Behavior on color {
                                CAnim {}
                            }
                        }
                    }
                }
            }
        }

        // ── Arrangement ──────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            visible: Hyprctl.monitors.length > 1
            spacing: Tokens.spacing.medium

            SectionHeader {
                text: qsTr("Arrangement")
            }

            // One card per OTHER monitor
            Repeater {
                model: Hyprctl.monitors

                delegate: SectionContainer {
                    id: targetSection

                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    contentSpacing: Tokens.spacing.small

                    visible: root.mon !== null && root.mon !== undefined && modelData.id !== root.mon.id

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: "tv"
                            fontStyle: Tokens.font.icon.medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Relative to Monitor %1 (%2)").arg(modelData.id ?? 0).arg(modelData.name ?? "")
                            font: Tokens.font.body.medium
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        columnSpacing: Tokens.spacing.small
                        rowSpacing: Tokens.spacing.small

                        Repeater {
                            model: [
                                {
                                    label: qsTr("Left"),
                                    pos: "left",
                                    icon: "arrow_back"
                                },
                                {
                                    label: qsTr("Right"),
                                    pos: "right",
                                    icon: "arrow_forward"
                                },
                                {
                                    label: qsTr("Above"),
                                    pos: "top",
                                    icon: "arrow_upward"
                                },
                                {
                                    label: qsTr("Below"),
                                    pos: "bottom",
                                    icon: "arrow_downward"
                                }
                            ]

                            delegate: ArrangeButton {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                btnIcon: modelData.icon
                                btnLabel: modelData.label
                                onClicked: {
                                    if (root.mon)
                                        Monitors.arrange(root.mon.name, modelData.pos, targetSection.modelData.id);
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Display information ───────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            SectionHeader {
                text: qsTr("Display information")
            }

            SectionContainer {
                contentSpacing: Tokens.spacing.small / 2

                PropertyRow {
                    label: qsTr("Name")
                    value: root.mon?.name ?? qsTr("Unknown")
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Monitor ID")
                    value: root.mon != null ? String(root.mon.id ?? "—") : "—"
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Resolution")
                    value: root.mon?.width && root.mon?.height ? qsTr("%1 × %2 px").arg(root.mon.width).arg(root.mon.height) : qsTr("N/A")
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Refresh rate")
                    value: root.mon?.refreshRate != null ? qsTr("%1 Hz").arg((root.mon.refreshRate).toFixed(3)) : qsTr("N/A")
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Position")
                    value: root.mon != null ? qsTr("x: %1, y: %2").arg(root.mon.x ?? 0).arg(root.mon.y ?? 0) : qsTr("N/A")
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Scale")
                    value: root.mon?.scale != null ? qsTr("×%1").arg((root.mon.scale).toFixed(2)) : qsTr("N/A")
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Transform")
                    value: {
                        const t = root.mon?.transform ?? 0;
                        return ["Normal (0°)", "90°", "180°", "270°", "Flipped", "Flipped 90°", "Flipped 180°", "Flipped 270°"][t] ?? qsTr("Unknown");
                    }
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Make / Model")
                    value: {
                        const parts = [root.mon?.make, root.mon?.model].filter(v => v && v.length > 0);
                        return parts.length > 0 ? parts.join(" ") : qsTr("Unknown");
                    }
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Serial")
                    value: root.mon?.serial || qsTr("Unknown")
                }
                PropertyRow {
                    showTopMargin: true
                    label: qsTr("Focused")
                    value: (root.mon?.focused ?? false) ? qsTr("Yes") : qsTr("No")
                }
            }
        }
    }

    // ── Reusable sub-components ───────────────────────────────────────

    component RotationChip: StyledRect {
        id: chip
        required property string chipLabel
        required property int chipAngle
        required property bool isActive
        signal clicked

        implicitHeight: 72
        radius: Tokens.rounding.large
        color: chip.isActive ? Colours.palette.m3secondaryContainer : Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

        StateLayer {
            color: chip.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
            function onClicked(): void {
                chip.clicked();
            }
        }

        ColumnLayout {
            id: chipContent
            anchors.centerIn: parent
            spacing: 2

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "screen_rotation"
                rotation: chip.chipAngle
                fontStyle: Tokens.font.icon.medium
                color: chip.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                Behavior on rotation {
                    Anim {}
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: chip.chipLabel
                font: Tokens.font.body.small
                color: chip.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
            }
        }

        Behavior on color {
            CAnim {}
        }
    }

    component ArrangeButton: StyledRect {
        id: arrangeBtn
        required property string btnIcon
        required property string btnLabel
        signal clicked

        implicitHeight: 64
        radius: Tokens.rounding.medium
        color: Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

        StateLayer {
            color: Colours.palette.m3onSurfaceVariant
            function onClicked(): void {
                arrangeBtn.clicked();
            }
        }

        ColumnLayout {
            id: btnContent
            anchors.centerIn: parent
            spacing: 2

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: arrangeBtn.btnIcon
                fontStyle: Tokens.font.icon.medium
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: arrangeBtn.btnLabel
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }
}
