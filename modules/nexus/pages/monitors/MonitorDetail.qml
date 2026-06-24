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

    readonly property var mon: nState.selectedMonitor
    readonly property var brightnessMon: mon ? Brightness.getMonitor(mon.name) : null

    onMonChanged: {
        if (!mon) {
            nState.closeSubPage();
        }
    }

    title: mon?.name ?? qsTr("Monitor")
    isSubPage: true

    readonly property list<MenuItem> refreshItems: [
        MenuItem { text: "30 Hz" },
        MenuItem { text: "50 Hz" },
        MenuItem { text: "59 Hz" },
        MenuItem { text: "60 Hz" }
    ]
    readonly property list<int> refreshValues: [30, 50, 59, 60]

    function getRefreshItem(): MenuItem {
        const rate = Math.round(root.mon?.refreshRate ?? 60);
        const idx = root.refreshValues.indexOf(rate);
        return idx >= 0 ? root.refreshItems[idx] : null;
    }

    readonly property list<MenuItem> rotationItems: [
        MenuItem { text: qsTr("0°") },
        MenuItem { text: "90°" },
        MenuItem { text: "180°" },
        MenuItem { text: "270°" }
    ]
    readonly property list<int> rotationValues: [0, 90, 180, 270]

    readonly property list<MenuItem> scaleItems: [
        MenuItem { text: "1.0×" },
        MenuItem { text: "1.25×" },
        MenuItem { text: "1.5×" },
        MenuItem { text: "2.0×" }
    ]
    readonly property list<real> scaleValues: [1.0, 1.25, 1.5, 2.0]

    function getScaleItem(): MenuItem {
        const s = root.mon?.scale ?? 1.0;
        const idx = root.scaleValues.findIndex(v => Math.abs(v - s) < 0.01);
        return idx >= 0 ? root.scaleItems[idx] : null;
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // ── Hero Section ──────────────────────────────────────
        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true
            implicitHeight: hero.implicitHeight + Tokens.padding.extraLarge * 2

            ColumnLayout {
                id: hero

                anchors.centerIn: parent
                width: parent.width - Tokens.padding.largeIncreased * 2
                spacing: Tokens.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "monitor"
                    fontStyle: Tokens.font.icon.extraLarge
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Tokens.spacing.small
                    text: root.mon?.name ?? qsTr("Unknown Monitor")
                    font: Tokens.font.headline.builders.small.build()
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        const w = root.mon?.width ?? 0;
                        const h = root.mon?.height ?? 0;
                        const r = root.mon?.refreshRate ?? 0;
                        if (w && h && r)
                            return qsTr("%1 × %2 @ %3 Hz").arg(w).arg(h).arg(r.toFixed(0));
                        return qsTr("Unavailable");
                    }
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.medium
                }
            }
        }

        // ── Settings ───────────────────────────────────────
        SectionHeader {
            text: qsTr("Configuration")
        }

        SliderRow {
            Layout.fillWidth: true
            first: true
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

        SelectRow {
            Layout.fillWidth: true
            first: root.brightnessMon === null || root.brightnessMon === undefined
            label: qsTr("Refresh rate")
            subtext: qsTr("Maximum refresh rate")
            menuItems: root.refreshItems
            active: root.getRefreshItem()
            fallbackText: root.mon?.refreshRate ? qsTr("%1 Hz").arg((root.mon.refreshRate).toFixed(0)) : qsTr("Unknown")
            fallbackIcon: "speed"
            onSelected: item => {
                const idx = root.refreshItems.indexOf(item);
                if (idx >= 0 && root.mon)
                    Monitors.setRefreshRate(root.mon.name, root.refreshValues[idx]);
            }
        }

        SelectRow {
            Layout.fillWidth: true
            label: qsTr("Rotation")
            subtext: qsTr("Screen orientation")
            menuItems: root.rotationItems
            active: {
                const t = root.mon?.transform ?? 0;
                return root.rotationItems[t] ?? root.rotationItems[0];
            }
            onSelected: item => {
                const idx = root.rotationItems.indexOf(item);
                if (idx >= 0 && root.mon)
                    Monitors.rotate(root.mon.name, root.rotationValues[idx]);
            }
        }

        SelectRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Scale")
            subtext: qsTr("UI scaling factor")
            menuItems: root.scaleItems
            active: root.getScaleItem()
            fallbackText: qsTr("%1×").arg((root.mon?.scale ?? 1.0).toFixed(2))
            fallbackIcon: "zoom_in"
            onSelected: item => {
                const idx = root.scaleItems.indexOf(item);
                if (idx >= 0 && root.mon)
                    Monitors.setScale(root.mon.name, root.scaleValues[idx]);
            }
        }

        // ── Arrangement ──────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            visible: Hyprctl.monitors.length > 1
            spacing: Tokens.spacing.extraSmall / 2

            SectionHeader {
                text: qsTr("Arrangement")
            }

            Repeater {
                model: Hyprctl.monitors

                delegate: ConnectedRect {
                    id: targetSection
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    first: index === 0
                    last: index === Hyprctl.monitors.length - 1
                    implicitHeight: arrangeLayout.implicitHeight + arrangeLayout.anchors.margins * 2
                    visible: root.mon !== null && root.mon !== undefined && modelData.id !== root.mon.id

                    ColumnLayout {
                        id: arrangeLayout
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.medium
                        anchors.leftMargin: Tokens.padding.largeIncreased
                        anchors.rightMargin: Tokens.padding.largeIncreased
                        spacing: Tokens.spacing.small

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
                                    { label: qsTr("Left"), pos: "left", icon: "arrow_back" },
                                    { label: qsTr("Right"), pos: "right", icon: "arrow_forward" },
                                    { label: qsTr("Above"), pos: "top", icon: "arrow_upward" },
                                    { label: qsTr("Below"), pos: "bottom", icon: "arrow_downward" }
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
        }

        // ── Display information ───────────────────────────────
        SectionHeader {
            text: qsTr("Display information")
        }

        InfoRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Position")
            value: root.mon != null ? qsTr("x: %1, y: %2").arg(root.mon.x ?? 0).arg(root.mon.y ?? 0) : qsTr("N/A")
        }
        InfoRow {
            Layout.fillWidth: true
            label: qsTr("Monitor ID")
            value: root.mon != null ? String(root.mon.id ?? "—") : "—"
        }
        InfoRow {
            Layout.fillWidth: true
            label: qsTr("Make / Model")
            value: {
                const parts = [root.mon?.make, root.mon?.model].filter(v => v && v.length > 0);
                return parts.length > 0 ? parts.join(" ") : qsTr("Unknown");
            }
        }
        InfoRow {
            Layout.fillWidth: true
            label: qsTr("Serial")
            value: root.mon?.serial || qsTr("Unknown")
        }
        InfoRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Focused")
            value: (root.mon?.focused ?? false) ? qsTr("Yes") : qsTr("No")
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
