pragma ComponentBehavior: Bound

import ".."
import "../components"
import "."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import Caelestia.Config
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session
    readonly property var monitorModel: Hyprctl.monitors

    function selectMonitor(monitor: var): void {
        if (!monitor)
            return;
        root.session.monitor.active = {
            id: monitor.id,
            name: monitor.name
        };
    }

    function selectedMonitor(): var {
        const active = root.session.monitor.active;
        if (!active)
            return null;

        for (const monitor of root.monitorModel) {
            if (monitor.name === active.name || monitor.id === active.id)
                return monitor;
        }

        return null;
    }

    function ensureSingleMonitorSelected(): void {
        if (!root.session.monitor.active && (root.monitorModel?.length ?? 0) === 1)
            root.selectMonitor(root.monitorModel[0]);
    }

    anchors.fill: parent

    Component.onCompleted: Qt.callLater(root.ensureSingleMonitorSelected)

    Connections {
        target: Hyprctl

        function onMonitorsChanged(): void {
            root.ensureSingleMonitorSelected();
        }
    }

    // ── Two-column split (mirrors NetworkingPane) ──────────────────────
    SplitPaneLayout {
        id: splitLayout

        anchors.fill: parent

        // ── LEFT: monitor list ─────────────────────────────────────────
        leftContent: Component {
            StyledFlickable {
                id: leftFlickable

                flickableDirection: Flickable.VerticalFlick
                contentHeight: leftContent.implicitHeight

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: leftFlickable
                }

                ColumnLayout {
                    id: leftContent

                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Tokens.spacing.normal

                    // Header row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.smaller

                        StyledText {
                            text: qsTr("Monitors")
                            font.pointSize: Tokens.font.size.large
                            font.weight: 500
                        }

                        Item { Layout.fillWidth: true }

                        // Identify toggle — only button in the header
                        ToggleButton {
                            toggled: Monitors.identifying
                            icon: "tv_signin"
                            accent: "Secondary"
                            iconSize: Tokens.font.size.normal
                            horizontalPadding: Tokens.padding.normal
                            verticalPadding: Tokens.padding.smaller
                            tooltip: qsTr("Identify monitors")

                            onClicked: Monitors.toggleIdentification()
                        }
                    }

                    // Subtitle
                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("%1 display(s) connected").arg(root.monitorModel.length)
                        color: Colours.palette.m3outline
                        font.pointSize: Tokens.font.size.small
                    }

                    // Monitor list — use hyprctl data so refresh rate and modes are available
                    Repeater {
                        model: root.monitorModel

                        delegate: MonitorListItem {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true

                            monitor: modelData
                            active: root.session.monitor.active !== null
                                && root.session.monitor.active !== undefined
                                && (root.session.monitor.active.id === modelData.id
                                    || root.session.monitor.active.name === modelData.name)

                            onClicked: root.selectMonitor(modelData)
                        }
                    }
                }
            }
        }

        // ── RIGHT: detail / overview ───────────────────────────────────
        rightContent: Component {
            Item {
                id: rightPaneItem

                property var selectedMonitor: root.selectedMonitor()
                property string paneId: selectedMonitor
                    ? ("mon:" + (selectedMonitor.name ?? ""))
                    : "overview"
                property Component targetComponent: overviewComponent
                property Component nextComponent: overviewComponent

                function resolveComponent(): Component {
                    return selectedMonitor ? monitorDetailComponent : overviewComponent;
                }

                Component.onCompleted: {
                    targetComponent = resolveComponent();
                    nextComponent = targetComponent;
                }

                Connections {
                    target: root.session.monitor
                    function onActiveChanged(): void {
                        rightPaneItem.selectedMonitor = root.selectedMonitor();
                        rightPaneItem.nextComponent = rightPaneItem.resolveComponent();
                    }
                }

                Connections {
                    target: Hyprctl
                    function onMonitorsChanged(): void {
                        rightPaneItem.selectedMonitor = root.selectedMonitor();
                        rightPaneItem.nextComponent = rightPaneItem.resolveComponent();
                    }
                }

                Loader {
                    id: rightLoader
                    anchors.fill: parent
                    opacity: 1
                    scale: 1
                    transformOrigin: Item.Center
                    asynchronous: true
                    sourceComponent: rightPaneItem.targetComponent
                }

                Behavior on paneId {
                    PaneTransition {
                        target: rightLoader
                        propertyActions: [
                            PropertyAction {
                                target: rightPaneItem
                                property: "targetComponent"
                                value: rightPaneItem.nextComponent
                            }
                        ]
                    }
                }
            }
        }
    }

    // ── List item component ───────────────────────────────────────────
    component MonitorListItem: Item {
        id: listItem

        required property var monitor
        required property bool active

        signal clicked()

        implicitHeight: itemRow.implicitHeight + Tokens.padding.normal * 2

        StyledRect {
            anchors.fill: parent
            radius: Tokens.rounding.normal
            color: Qt.alpha(
                Colours.tPalette.m3surfaceContainer,
                listItem.active ? Colours.tPalette.m3surfaceContainer.a : 0
            )

            StateLayer {
                function onClicked(): void { listItem.clicked(); }
            }

            RowLayout {
                id: itemRow

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Tokens.padding.normal
                spacing: Tokens.spacing.normal

                // Monitor icon badge
                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: monIcon.implicitHeight + Tokens.padding.normal * 2
                    radius: Tokens.rounding.normal
                    color: listItem.active
                        ? Colours.palette.m3primaryContainer
                        : Colours.tPalette.m3surfaceContainerHigh

                    MaterialIcon {
                        id: monIcon
                        anchors.centerIn: parent
                        text: "monitor"
                        font.pointSize: Tokens.font.size.large
                        fill: listItem.active ? 1 : 0
                        color: listItem.active
                            ? Colours.palette.m3onPrimaryContainer
                            : Colours.palette.m3onSurface
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
                        text: listItem.monitor?.name ?? ""
                        font.weight: listItem.active ? 600 : 400
                    }

                    StyledText {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.pointSize: Tokens.font.size.small
                        color: Colours.palette.m3outline
                        text: {
                            const m = listItem.monitor;
                            if (!m || !m.width || !m.height) return qsTr("Unavailable");
                            const rr = m.refreshRate ?? 0;
                            return qsTr("%1×%2 @ %3 Hz").arg(m.width).arg(m.height).arg(rr.toFixed(0));
                        }
                    }
                }

                // Focused badge
                StyledRect {
                    visible: listItem.monitor?.focused ?? false
                    implicitWidth: focusedLabel.implicitWidth + Tokens.padding.normal * 2
                    implicitHeight: focusedLabel.implicitHeight + Tokens.padding.small * 2
                    radius: Tokens.rounding.full
                    color: Qt.alpha(Colours.palette.m3primaryContainer, 0.9)

                    StyledText {
                        id: focusedLabel
                        anchors.centerIn: parent
                        text: qsTr("Active")
                        font.pointSize: Tokens.font.size.small
                        color: Colours.palette.m3onPrimaryContainer
                    }
                }

                // Chevron
                MaterialIcon {
                    text: "chevron_right"
                    color: Colours.palette.m3outline
                    opacity: listItem.active ? 1 : 0.4
                }
            }

            Behavior on color { CAnim {} }
        }
    }

    // ── Overview component (no monitor selected) ──────────────────────
    Component {
        id: overviewComponent

        StyledFlickable {
            id: overviewFlickable
            flickableDirection: Flickable.VerticalFlick
            contentHeight: overviewInner.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: overviewFlickable
            }

            ColumnLayout {
                id: overviewInner

                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Tokens.spacing.normal

                SettingsHeader {
                    icon: "monitor"
                    title: qsTr("Monitors")
                }

                SectionHeader {
                    title: qsTr("Display layout")
                    description: qsTr("Summary of connected displays")
                }

                SectionContainer {
                    contentSpacing: Tokens.spacing.small

                    Repeater {
                        model: root.monitorModel

                        delegate: PropertyRow {
                            required property var modelData
                            required property int index

                            label: qsTr("Monitor %1 – %2")
                                .arg(modelData.id ?? index)
                                .arg(modelData.name ?? "")
                            value: {
                                const m = modelData;
                                if (!m || !m.width || !m.height) return qsTr("No data");
                                return qsTr("%1×%2 @ %3 Hz  ·  pos %4,%5  ·  ×%6 scale")
                                    .arg(m.width).arg(m.height)
                                    .arg((m.refreshRate ?? 0).toFixed(0))
                                    .arg(m.x ?? 0).arg(m.y ?? 0)
                                    .arg((m.scale ?? 1).toFixed(2));
                            }
                            showTopMargin: index > 0
                        }
                    }
                }

                SectionHeader {
                    title: qsTr("Quick controls")
                    description: qsTr("Select a monitor on the left to configure it")
                }

                SectionContainer {
                    contentSpacing: Tokens.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.normal

                        MaterialIcon {
                            text: "tv_signin"
                            font.pointSize: Tokens.font.size.large
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            StyledText {
                                text: qsTr("Identify displays")
                                font.pointSize: Tokens.font.size.normal
                            }
                            StyledText {
                                text: qsTr("Show monitor IDs on each screen")
                                color: Colours.palette.m3outline
                                font.pointSize: Tokens.font.size.small
                            }
                        }

                        ToggleButton {
                            toggled: Monitors.identifying
                            icon: Monitors.identifying ? "visibility_off" : "visibility"
                            accent: "Secondary"
                            onClicked: Monitors.toggleIdentification()
                        }
                    }
                }
            }
        }
    }

    // ── Per-monitor detail component ──────────────────────────────────
    Component {
        id: monitorDetailComponent

        StyledFlickable {
            id: detailFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: detailInner.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: detailFlickable
            }

            readonly property var mon: root.selectedMonitor()
            readonly property var brightnessMon: mon ? Brightness.getMonitor(mon.name) : null

            ColumnLayout {
                id: detailInner

                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Tokens.spacing.normal

                // ── Header ──────────────────────────────────────────
                ConnectionHeader {
                    icon: "monitor"
                    title: detailFlickable.mon?.name ?? qsTr("Monitor")
                }

                // ── Brightness ───────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: detailFlickable.brightnessMon !== null
                        && detailFlickable.brightnessMon !== undefined
                    spacing: Tokens.spacing.normal

                    SectionHeader {
                        title: qsTr("Brightness")
                        description: qsTr("Adjust display brightness")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.normal

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.normal

                            MaterialIcon {
                                text: (detailFlickable.brightnessMon?.brightness ?? 0) > 0.5
                                    ? "brightness_high" : "brightness_low"
                                font.pointSize: Tokens.font.size.normal
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                implicitHeight: Tokens.padding.normal * 3
                                from: 0; to: 1; stepSize: 0.01
                                value: detailFlickable.brightnessMon?.brightness ?? 0
                                onMoved: detailFlickable.brightnessMon?.setBrightness(value)
                            }

                            StyledText {
                                text: qsTr("%1%").arg(
                                    Math.round((detailFlickable.brightnessMon?.brightness ?? 0) * 100))
                                Layout.preferredWidth: 38
                                font.pointSize: Tokens.font.size.small
                                color: Colours.palette.m3outline
                            }
                        }
                    }
                }

                // ── Refresh rate ─────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    SectionHeader {
                        title: qsTr("Refresh rate")
                        description: qsTr("Set the display refresh rate")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.normal

                        SpinBoxRow {
                            Layout.fillWidth: true
                            label: qsTr("Refresh rate")
                            value: detailFlickable.mon?.refreshRate ?? 60
                            min: 10
                            max: 1000
                            step: 0.01
                            onValueModified: value => {
                                if (detailFlickable.mon)
                                    Monitors.setRefreshRate(detailFlickable.mon.name, value);
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: (detailFlickable.mon?.availableModes?.length ?? 0) > 0
                            spacing: Tokens.spacing.small

                            Repeater {
                                model: detailFlickable.mon?.availableModes ?? []

                                delegate: StyledRect {
                                    required property string modelData
                                    required property int index

                                    Layout.fillWidth: true
                                    implicitHeight: modeLabel.implicitHeight + Tokens.padding.normal * 2
                                    radius: Tokens.rounding.full

                                    readonly property real modeRate: {
                                        const match = modelData.match(/@(\d+(?:\.\d+)?)Hz/);
                                        return match ? parseFloat(match[1]) : 0;
                                    }
                                    readonly property bool isActive: Math.abs((detailFlickable.mon?.refreshRate ?? 0) - modeRate) < 0.1

                                    color: isActive
                                        ? Colours.palette.m3secondaryContainer
                                        : Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

                                    StateLayer {
                                        color: parent.isActive
                                            ? Colours.palette.m3onSecondaryContainer
                                            : Colours.palette.m3onSurfaceVariant
                                        onClicked: {
                                            if (detailFlickable.mon && parent.modeRate > 0)
                                                Monitors.setRefreshRate(detailFlickable.mon.name, parent.modeRate);
                                        }
                                    }

                                    StyledText {
                                        id: modeLabel
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pointSize: Tokens.font.size.small
                                        color: parent.isActive
                                            ? Colours.palette.m3onSecondaryContainer
                                            : Colours.palette.m3onSurfaceVariant
                                    }

                                    Behavior on color { CAnim {} }
                                }
                            }
                        }
                    }
                }

                // ── Rotation ─────────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    SectionHeader {
                        title: qsTr("Rotation")
                        description: qsTr("Rotate this display")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            Repeater {
                                model: [
                                    { label: qsTr("0°"),   transform: 0, angle: 0   },
                                    { label: qsTr("90°"),  transform: 1, angle: 90  },
                                    { label: qsTr("180°"), transform: 2, angle: 180 },
                                    { label: qsTr("270°"), transform: 3, angle: 270 }
                                ]

                                delegate: RotationChip {
                                    required property var modelData
                                    required property int index

                                    Layout.fillWidth: true
                                    chipLabel: modelData.label
                                    chipAngle: modelData.angle
                                    isActive: (detailFlickable.mon?.transform ?? 0) === modelData.transform
                                    onClicked: {
                                        if (detailFlickable.mon)
                                            Monitors.rotate(detailFlickable.mon.name, modelData.angle);
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Scale ────────────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    SectionHeader {
                        title: qsTr("Scale")
                        description: qsTr("DPI scaling factor for this display")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.normal

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.normal

                            MaterialIcon {
                                text: "zoom_in"
                                font.pointSize: Tokens.font.size.normal
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StyledSlider {
                                id: scaleSlider
                                Layout.fillWidth: true
                                implicitHeight: Tokens.padding.normal * 3
                                from: 0.5; to: 3.0; stepSize: 0.25
                                value: detailFlickable.mon?.scale ?? 1

                                onMoved: {
                                    if (detailFlickable.mon)
                                        Monitors.setScale(detailFlickable.mon.name, value);
                                }
                            }

                            StyledText {
                                text: qsTr("×%1").arg((detailFlickable.mon?.scale ?? 1).toFixed(2))
                                Layout.preferredWidth: 42
                                font.pointSize: Tokens.font.size.small
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
                                    implicitHeight: scaleChipLabel.implicitHeight + Tokens.padding.normal * 2
                                    radius: Tokens.rounding.full

                                    readonly property bool isActive:
                                        Math.abs((detailFlickable.mon?.scale ?? 1) - modelData) < 0.01

                                    color: isActive
                                        ? Colours.palette.m3secondaryContainer
                                        : Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

                                    StateLayer {
                                        color: parent.isActive
                                            ? Colours.palette.m3onSecondaryContainer
                                            : Colours.palette.m3onSurfaceVariant
                                        function onClicked(): void {
                                            if (detailFlickable.mon)
                                                Monitors.setScale(detailFlickable.mon.name, modelData);
                                        }
                                    }

                                    StyledText {
                                        id: scaleChipLabel
                                        anchors.centerIn: parent
                                        text: qsTr("×%1").arg(modelData.toFixed(2))
                                        font.pointSize: Tokens.font.size.small
                                        color: parent.isActive
                                            ? Colours.palette.m3onSecondaryContainer
                                            : Colours.palette.m3onSurfaceVariant
                                    }

                                    Behavior on color { CAnim {} }
                                }
                            }
                        }
                    }
                }

                // ── Arrangement ──────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: root.monitorModel.length > 1
                    spacing: Tokens.spacing.normal

                    SectionHeader {
                        title: qsTr("Arrangement")
                        description: qsTr("Position this display relative to another")
                    }

                    // One card per OTHER monitor — use visible to skip self
                    Repeater {
                        model: root.monitorModel

                        delegate: SectionContainer {
                            id: targetSection

                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            contentSpacing: Tokens.spacing.small

                            // Hide the current monitor's own entry without JS filter
                            visible: detailFlickable.mon !== null
                                && detailFlickable.mon !== undefined
                                && modelData.id !== detailFlickable.mon.id
                            height: visible ? implicitHeight : 0

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.small

                                MaterialIcon {
                                    text: "tv"
                                    font.pointSize: Tokens.font.size.normal
                                    color: Colours.palette.m3onSurfaceVariant
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: qsTr("Relative to Monitor %1 (%2)")
                                        .arg(modelData.id ?? 0)
                                        .arg(modelData.name ?? "")
                                    font.pointSize: Tokens.font.size.normal
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 4
                                columnSpacing: Tokens.spacing.small
                                rowSpacing: Tokens.spacing.small

                                Repeater {
                                    model: [
                                        { label: qsTr("Left"),  pos: "left",   icon: "arrow_back"     },
                                        { label: qsTr("Right"), pos: "right",  icon: "arrow_forward"  },
                                        { label: qsTr("Above"), pos: "top",    icon: "arrow_upward"   },
                                        { label: qsTr("Below"), pos: "bottom", icon: "arrow_downward" }
                                    ]

                                    delegate: ArrangeButton {
                                        required property var modelData
                                        required property int index

                                        Layout.fillWidth: true
                                        btnIcon: modelData.icon
                                        btnLabel: modelData.label
                                        onClicked: {
                                            if (detailFlickable.mon)
                                                Monitors.arrange(
                                                    detailFlickable.mon.name,
                                                    modelData.pos,
                                                    targetSection.modelData.id
                                                );
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
                    spacing: Tokens.spacing.normal

                    SectionHeader {
                        title: qsTr("Display information")
                        description: qsTr("Hardware and layout details")
                    }

                    SectionContainer {
                        contentSpacing: Tokens.spacing.small / 2

                        PropertyRow {
                            label: qsTr("Name")
                            value: detailFlickable.mon?.name ?? qsTr("Unknown")
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Monitor ID")
                            value: detailFlickable.mon != null ? String(detailFlickable.mon.id ?? "—") : "—"
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Resolution")
                            value: detailFlickable.mon?.width && detailFlickable.mon?.height
                                ? qsTr("%1 × %2 px").arg(detailFlickable.mon.width).arg(detailFlickable.mon.height)
                                : qsTr("N/A")
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Refresh rate")
                            value: detailFlickable.mon?.refreshRate != null
                                ? qsTr("%1 Hz").arg((detailFlickable.mon.refreshRate).toFixed(3))
                                : qsTr("N/A")
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Position")
                            value: detailFlickable.mon != null
                                ? qsTr("x: %1, y: %2").arg(detailFlickable.mon.x ?? 0).arg(detailFlickable.mon.y ?? 0)
                                : qsTr("N/A")
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Scale")
                            value: detailFlickable.mon?.scale != null
                                ? qsTr("×%1").arg((detailFlickable.mon.scale).toFixed(2))
                                : qsTr("N/A")
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Transform")
                            value: {
                                const t = detailFlickable.mon?.transform ?? 0;
                                return ["Normal (0°)", "90°", "180°", "270°",
                                        "Flipped", "Flipped 90°", "Flipped 180°", "Flipped 270°"][t]
                                    ?? qsTr("Unknown");
                            }
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Make / Model")
                            value: {
                                const parts = [detailFlickable.mon?.make, detailFlickable.mon?.model]
                                    .filter(v => v && v.length > 0);
                                return parts.length > 0 ? parts.join(" ") : qsTr("Unknown");
                            }
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Serial")
                            value: detailFlickable.mon?.serial || qsTr("Unknown")
                        }
                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Focused")
                            value: (detailFlickable.mon?.focused ?? false) ? qsTr("Yes") : qsTr("No")
                        }
                    }
                }
            }
        }
    }

    // ── Reusable sub-components ───────────────────────────────────────

    component RotationChip: Item {
        id: chip
        required property string chipLabel
        required property int chipAngle
        required property bool isActive
        signal clicked()

        implicitHeight: chipContent.implicitHeight + Tokens.padding.normal * 2

        StyledRect {
            anchors.fill: parent
            radius: Tokens.rounding.full
            color: chip.isActive
                ? Colours.palette.m3secondaryContainer
                : Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

            StateLayer {
                color: chip.isActive
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.palette.m3onSurfaceVariant
                function onClicked(): void { chip.clicked(); }
            }

            ColumnLayout {
                id: chipContent
                anchors.centerIn: parent
                spacing: 2

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "screen_rotation"
                    rotation: chip.chipAngle
                    font.pointSize: Tokens.font.size.normal
                    color: chip.isActive
                        ? Colours.palette.m3onSecondaryContainer
                        : Colours.palette.m3onSurfaceVariant
                    Behavior on rotation { Anim {} }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: chip.chipLabel
                    font.pointSize: Tokens.font.size.small
                    color: chip.isActive
                        ? Colours.palette.m3onSecondaryContainer
                        : Colours.palette.m3onSurfaceVariant
                }
            }

            Behavior on color { CAnim {} }
        }
    }

    component ArrangeButton: Item {
        id: arrangeBtn
        required property string btnIcon
        required property string btnLabel
        signal clicked()

        implicitHeight: btnContent.implicitHeight + Tokens.padding.normal * 2

        StyledRect {
            anchors.fill: parent
            radius: Tokens.rounding.normal
            color: Qt.alpha(Colours.palette.m3surfaceVariant, 0.5)

            StateLayer {
                color: Colours.palette.m3onSurfaceVariant
                function onClicked(): void { arrangeBtn.clicked(); }
            }

            ColumnLayout {
                id: btnContent
                anchors.centerIn: parent
                spacing: 2

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: arrangeBtn.btnIcon
                    font.pointSize: Tokens.font.size.normal
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: arrangeBtn.btnLabel
                    font.pointSize: Tokens.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }
}
