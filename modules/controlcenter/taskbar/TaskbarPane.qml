pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    required property Session session

    property bool activeWindowCompact: Config.bar.activeWindow.compact ?? false
    property bool activeWindowInverted: Config.bar.activeWindow.inverted ?? false
    property bool clockShowIcon: Config.bar.clock.showIcon ?? true
    property bool clockBackground: Config.bar.clock.background ?? false
    property bool clockShowDate: Config.bar.clock.showDate ?? false
    property bool persistent: Config.bar.persistent ?? true
    property bool showOnHover: Config.bar.showOnHover ?? true
    property int dragThreshold: Config.bar.dragThreshold ?? 20
    property bool showAudio: Config.bar.status.showAudio ?? true
    property bool showMicrophone: Config.bar.status.showMicrophone ?? true
    property bool showKbLayout: Config.bar.status.showKbLayout ?? false
    property bool showNetwork: Config.bar.status.showNetwork ?? true
    property bool showWifi: Config.bar.status.showWifi ?? true
    property bool showBluetooth: Config.bar.status.showBluetooth ?? true
    property bool showBattery: Config.bar.status.showBattery ?? true
    property bool showLockStatus: Config.bar.status.showLockStatus ?? true
    property bool trayBackground: Config.bar.tray.background ?? false
    property bool trayCompact: Config.bar.tray.compact ?? false
    property bool trayRecolour: Config.bar.tray.recolour ?? false
    property int workspacesShown: Config.bar.workspaces.shown ?? 5
    property bool workspacesActiveIndicator: Config.bar.workspaces.activeIndicator ?? true
    property bool workspacesOccupiedBg: Config.bar.workspaces.occupiedBg ?? false
    property bool workspacesShowWindows: Config.bar.workspaces.showWindows ?? false
    property int workspacesMaxWindowIcons: Config.bar.workspaces.maxWindowIcons ?? 0
    property bool workspacesPerMonitor: GlobalConfig.bar.workspaces.perMonitorWorkspaces ?? true
    property bool scrollWorkspaces: Config.bar.scrollActions.workspaces ?? true
    property bool scrollVolume: Config.bar.scrollActions.volume ?? true
    property bool scrollBrightness: Config.bar.scrollActions.brightness ?? true
    property bool popoutActiveWindow: Config.bar.popouts.activeWindow ?? true
    property bool popoutTray: Config.bar.popouts.tray ?? true
    property bool popoutStatusIcons: Config.bar.popouts.statusIcons ?? true
    property list<string> monitorNames: Hypr.monitorNames()
    property list<string> excludedScreens: Config.bar.excludedScreens ?? []

    function saveConfig(entryIndex, entryEnabled) {
        GlobalConfig.bar.activeWindow.compact = root.activeWindowCompact;
        GlobalConfig.bar.activeWindow.inverted = root.activeWindowInverted;
        GlobalConfig.bar.clock.background = root.clockBackground;
        GlobalConfig.bar.clock.showDate = root.clockShowDate;
        GlobalConfig.bar.clock.showIcon = root.clockShowIcon;
        GlobalConfig.bar.persistent = root.persistent;
        GlobalConfig.bar.showOnHover = root.showOnHover;
        GlobalConfig.bar.dragThreshold = root.dragThreshold;
        GlobalConfig.bar.status.showAudio = root.showAudio;
        GlobalConfig.bar.status.showMicrophone = root.showMicrophone;
        GlobalConfig.bar.status.showKbLayout = root.showKbLayout;
        GlobalConfig.bar.status.showNetwork = root.showNetwork;
        GlobalConfig.bar.status.showWifi = root.showWifi;
        GlobalConfig.bar.status.showBluetooth = root.showBluetooth;
        GlobalConfig.bar.status.showBattery = root.showBattery;
        GlobalConfig.bar.status.showLockStatus = root.showLockStatus;
        GlobalConfig.bar.tray.background = root.trayBackground;
        GlobalConfig.bar.tray.compact = root.trayCompact;
        GlobalConfig.bar.tray.recolour = root.trayRecolour;
        GlobalConfig.bar.workspaces.shown = root.workspacesShown;
        GlobalConfig.bar.workspaces.activeIndicator = root.workspacesActiveIndicator;
        GlobalConfig.bar.workspaces.occupiedBg = root.workspacesOccupiedBg;
        GlobalConfig.bar.workspaces.showWindows = root.workspacesShowWindows;
        GlobalConfig.bar.workspaces.maxWindowIcons = root.workspacesMaxWindowIcons;
        GlobalConfig.bar.workspaces.perMonitorWorkspaces = root.workspacesPerMonitor;
        GlobalConfig.bar.scrollActions.workspaces = root.scrollWorkspaces;
        GlobalConfig.bar.scrollActions.volume = root.scrollVolume;
        GlobalConfig.bar.scrollActions.brightness = root.scrollBrightness;
        GlobalConfig.bar.popouts.activeWindow = root.popoutActiveWindow;
        GlobalConfig.bar.popouts.tray = root.popoutTray;
        GlobalConfig.bar.popouts.statusIcons = root.popoutStatusIcons;
        GlobalConfig.bar.excludedScreens = root.excludedScreens;

        const entries = [];
        for (let i = 0; i < entriesModel.count; i++) {
            const entry = entriesModel.get(i);
            let enabled = entry.enabled;
            if (entryIndex !== undefined && i === entryIndex) {
                enabled = entryEnabled;
            }
            entries.push({
                id: entry.id,
                enabled: enabled
            });
        }
        GlobalConfig.bar.entries = entries;
    }

    anchors.fill: parent

    Component.onCompleted: {
        if (Config.bar.entries) {
            entriesModel.clear();
            for (let i = 0; i < Config.bar.entries.length; i++) {
                const entry = Config.bar.entries[i];
                entriesModel.append({
                    id: entry.id,
                    enabled: entry.enabled !== false
                });
            }
        }
    }

    ListModel {
        id: entriesModel
    }

    readonly property var sections: [
        { id: "statusIcons",   title: qsTr("Status Icons"),   description: qsTr("Toggle bar status icons"),    icon: "speaker" },
        { id: "workspaces",    title: qsTr("Workspaces"),     description: qsTr("Workspace display options"),  icon: "grid_view" },
        { id: "scrollActions", title: qsTr("Scroll Actions"), description: qsTr("Mouse scroll bindings"),      icon: "swap_vert" },
        { id: "clock",         title: qsTr("Clock"),          description: qsTr("Clock appearance"),           icon: "schedule" },
        { id: "barBehavior",   title: qsTr("Bar Behavior"),   description: qsTr("Show/hide and drag"),         icon: "view_agenda" },
        { id: "activeWindow",  title: qsTr("Active Window"),  description: qsTr("Active window style"),        icon: "web_asset" },
        { id: "popouts",       title: qsTr("Popouts"),        description: qsTr("Floating popout visibility"), icon: "open_in_new" },
        { id: "traySettings",  title: qsTr("Tray Settings"),  description: qsTr("System tray appearance"),     icon: "apps" },
        { id: "monitors",      title: qsTr("Monitors"),       description: qsTr("Per-monitor exclusions"),     icon: "monitor" }
    ]

    property string activeSection: "statusIcons"

    function componentForSection(sectionId) {
        switch (sectionId) {
        case "workspaces":    return workspacesComponent;
        case "scrollActions": return scrollActionsComponent;
        case "clock":         return clockComponent;
        case "barBehavior":   return barBehaviorComponent;
        case "activeWindow":  return activeWindowComponent;
        case "popouts":       return popoutsComponent;
        case "traySettings":  return traySettingsComponent;
        case "monitors":      return monitorsComponent;
        case "statusIcons":
        default:              return statusIconsComponent;
        }
    }

    SplitPaneLayout {
        anchors.fill: parent
        leftWidthRatio: 0.32
        leftMinimumWidth: 300

        leftContent: Component {
            StyledFlickable {
                id: leftFlickable

                flickableDirection: Flickable.VerticalFlick
                contentHeight: leftContentLayout.height

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: leftFlickable
                }

                ColumnLayout {
                    id: leftContentLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Tokens.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.smaller

                        StyledText {
                            text: qsTr("Taskbar")
                            font.pointSize: Tokens.font.size.large
                            font.weight: 500
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Repeater {
                        model: root.sections

                        delegate: SectionNavButton {
                            required property var modelData

                            Layout.fillWidth: true
                            section: modelData
                            active: root.activeSection === modelData.id
                            onClicked: root.activeSection = modelData.id
                        }
                    }
                }
            }
        }

        rightContent: Component {
            Item {
                id: rightPaneItem

                property string paneId: root.activeSection
                property Component targetComponent: root.componentForSection(root.activeSection)
                property Component nextComponent: root.componentForSection(root.activeSection)

                onPaneIdChanged: {
                    nextComponent = root.componentForSection(root.activeSection);
                }

                Loader {
                    id: rightLoader

                    anchors.fill: parent
                    asynchronous: true
                    opacity: 1
                    scale: 1
                    transformOrigin: Item.Center
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

    // ── Section content components ────────────────────────────────────────────
    // Background rule:
    //   ConnectedButtonGroup & SwitchRow already carry their own bg card —
    //   no SectionContainer wrapper needed around them.
    //   SliderInput / CustomSpinBox have no bg — wrap in SectionContainer.

    Component {
        id: statusIconsComponent

        SectionPage {
            title: qsTr("Status Icons")
            subtitle: qsTr("Toggle which icons appear in the status bar.")

            // ConnectedButtonGroup has its own bg — no SectionContainer needed
            ConnectedButtonGroup {
                Layout.fillWidth: true
                rootItem: root

                options: [
                    { label: qsTr("Speakers"),   propertyName: "showAudio",      onToggled: function(c) { root.showAudio = c;      root.saveConfig(); } },
                    { label: qsTr("Microphone"), propertyName: "showMicrophone", onToggled: function(c) { root.showMicrophone = c; root.saveConfig(); } },
                    { label: qsTr("Keyboard"),   propertyName: "showKbLayout",   onToggled: function(c) { root.showKbLayout = c;   root.saveConfig(); } },
                    { label: qsTr("Network"),    propertyName: "showNetwork",    onToggled: function(c) { root.showNetwork = c;    root.saveConfig(); } },
                    { label: qsTr("Wifi"),       propertyName: "showWifi",       onToggled: function(c) { root.showWifi = c;       root.saveConfig(); } },
                    { label: qsTr("Bluetooth"),  propertyName: "showBluetooth",  onToggled: function(c) { root.showBluetooth = c;  root.saveConfig(); } },
                    { label: qsTr("Battery"),    propertyName: "showBattery",    onToggled: function(c) { root.showBattery = c;    root.saveConfig(); } },
                    { label: qsTr("Capslock"),   propertyName: "showLockStatus", onToggled: function(c) { root.showLockStatus = c; root.saveConfig(); } }
                ]
            }
        }
    }

    Component {
        id: workspacesComponent

        SectionPage {
            title: qsTr("Workspaces")
            subtitle: qsTr("Configure workspace display in the bar.")

            // Spinbox rows have no bg — group in SectionContainer
            SectionContainer {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Shown")
                    }

                    CustomSpinBox {
                        min: 1
                        max: 20
                        value: root.workspacesShown
                        onValueModified: v => {
                            root.workspacesShown = v;
                            root.saveConfig();
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Max window icons")
                    }

                    CustomSpinBox {
                        min: 0
                        max: 20
                        value: root.workspacesMaxWindowIcons
                        onValueModified: v => {
                            root.workspacesMaxWindowIcons = v;
                            root.saveConfig();
                        }
                    }
                }
            }

            // SwitchRow has its own bg — standalone cards
            SwitchRow {
                label: qsTr("Active indicator")
                checked: root.workspacesActiveIndicator
                onToggled: checked => {
                    root.workspacesActiveIndicator = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Occupied background")
                checked: root.workspacesOccupiedBg
                onToggled: checked => {
                    root.workspacesOccupiedBg = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Show windows")
                checked: root.workspacesShowWindows
                onToggled: checked => {
                    root.workspacesShowWindows = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Per monitor workspaces")
                checked: root.workspacesPerMonitor
                onToggled: checked => {
                    root.workspacesPerMonitor = checked;
                    root.saveConfig();
                }
            }
        }
    }

    Component {
        id: scrollActionsComponent

        SectionPage {
            title: qsTr("Scroll Actions")
            subtitle: qsTr("Choose which actions mouse scrolling triggers.")

            ConnectedButtonGroup {
                Layout.fillWidth: true
                rootItem: root

                options: [
                    { label: qsTr("Workspaces"), propertyName: "scrollWorkspaces", onToggled: function(c) { root.scrollWorkspaces = c; root.saveConfig(); } },
                    { label: qsTr("Volume"),     propertyName: "scrollVolume",     onToggled: function(c) { root.scrollVolume = c;     root.saveConfig(); } },
                    { label: qsTr("Brightness"), propertyName: "scrollBrightness", onToggled: function(c) { root.scrollBrightness = c; root.saveConfig(); } }
                ]
            }
        }
    }

    Component {
        id: clockComponent

        SectionPage {
            title: qsTr("Clock")
            subtitle: qsTr("Adjust the clock appearance in the bar.")

            // SwitchRow has its own bg — no SectionContainer wrapper
            SwitchRow {
                label: qsTr("Background")
                checked: root.clockBackground
                onToggled: checked => {
                    root.clockBackground = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Show date")
                checked: root.clockShowDate
                onToggled: checked => {
                    root.clockShowDate = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Show clock icon")
                checked: root.clockShowIcon
                onToggled: checked => {
                    root.clockShowIcon = checked;
                    root.saveConfig();
                }
            }
        }
    }

    Component {
        id: barBehaviorComponent

        SectionPage {
            title: qsTr("Bar Behavior")
            subtitle: qsTr("Control when the bar appears and how drag reveal feels.")

            // SwitchRow has its own bg — standalone
            SwitchRow {
                label: qsTr("Persistent")
                checked: root.persistent
                onToggled: checked => {
                    root.persistent = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Show on hover")
                checked: root.showOnHover
                onToggled: checked => {
                    root.showOnHover = checked;
                    root.saveConfig();
                }
            }

            // SliderInput has no bg — wrap in SectionContainer
            SectionContainer {
                Layout.fillWidth: true
                contentSpacing: Tokens.spacing.normal

                SliderInput {
                    Layout.fillWidth: true
                    label: qsTr("Drag threshold")
                    value: root.dragThreshold
                    from: 0
                    to: 100
                    suffix: "px"
                    validator: IntValidator {
                        bottom: 0
                        top: 100
                    }
                    formatValueFunction: val => Math.round(val).toString()
                    parseValueFunction: text => parseInt(text)
                    onValueModified: newValue => {
                        root.dragThreshold = Math.round(newValue);
                        root.saveConfig();
                    }
                }
            }
        }
    }

    Component {
        id: activeWindowComponent

        SectionPage {
            title: qsTr("Active Window")
            subtitle: qsTr("Configure the active window button style.")

            SwitchRow {
                label: qsTr("Compact")
                checked: root.activeWindowCompact
                onToggled: checked => {
                    root.activeWindowCompact = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Inverted")
                checked: root.activeWindowInverted
                onToggled: checked => {
                    root.activeWindowInverted = checked;
                    root.saveConfig();
                }
            }
        }
    }

    Component {
        id: popoutsComponent

        SectionPage {
            title: qsTr("Popouts")
            subtitle: qsTr("Choose which bar elements float as popouts.")

            SwitchRow {
                label: qsTr("Active window")
                checked: root.popoutActiveWindow
                onToggled: checked => {
                    root.popoutActiveWindow = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Tray")
                checked: root.popoutTray
                onToggled: checked => {
                    root.popoutTray = checked;
                    root.saveConfig();
                }
            }

            SwitchRow {
                label: qsTr("Status icons")
                checked: root.popoutStatusIcons
                onToggled: checked => {
                    root.popoutStatusIcons = checked;
                    root.saveConfig();
                }
            }
        }
    }

    Component {
        id: traySettingsComponent

        SectionPage {
            title: qsTr("Tray Settings")
            subtitle: qsTr("Change the system tray presentation.")

            ConnectedButtonGroup {
                Layout.fillWidth: true
                rootItem: root

                options: [
                    { label: qsTr("Background"), propertyName: "trayBackground", onToggled: function(c) { root.trayBackground = c; root.saveConfig(); } },
                    { label: qsTr("Compact"),    propertyName: "trayCompact",    onToggled: function(c) { root.trayCompact = c;    root.saveConfig(); } },
                    { label: qsTr("Recolour"),   propertyName: "trayRecolour",   onToggled: function(c) { root.trayRecolour = c;   root.saveConfig(); } }
                ]
            }
        }
    }

    Component {
        id: monitorsComponent

        SectionPage {
            title: qsTr("Monitors")
            subtitle: qsTr("Choose which monitors display the bar.")

            ConnectedButtonGroup {
                Layout.fillWidth: true
                rootItem: root
                rows: Math.ceil(root.monitorNames.length / 3)

                options: root.monitorNames.map(e => ({
                    label: qsTr(e),
                    propertyName: "monitor" + e,
                    onToggled: function (_) {
                        let addedBack = excludedScreens.includes(e);
                        if (addedBack) {
                            const idx = excludedScreens.indexOf(e);
                            if (idx !== -1)
                                excludedScreens.splice(idx, 1);
                        } else {
                            if (!excludedScreens.includes(e))
                                excludedScreens.push(e);
                        }
                        root.saveConfig();
                    },
                    state: !Strings.testRegexList(root.excludedScreens, e)
                }))
            }
        }
    }

    // ── Inline component definitions ──────────────────────────────────────────

    component SectionPage: StyledFlickable {
        id: sectionPage

        required property string title
        property string subtitle: ""
        default property alias contentItems: contentLayout.data

        flickableDirection: Flickable.VerticalFlick
        contentHeight: contentLayout.height

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: sectionPage
        }

        ColumnLayout {
            id: contentLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: Tokens.spacing.normal

            StyledText {
                Layout.fillWidth: true
                text: sectionPage.title
                font.pointSize: Tokens.font.size.extraLarge
                font.weight: 600
            }

            StyledText {
                Layout.fillWidth: true
                Layout.bottomMargin: Tokens.spacing.small
                text: sectionPage.subtitle
                color: Colours.palette.m3outline
                visible: text.length > 0
                wrapMode: Text.WordWrap
            }
        }
    }

    component SectionNavButton: StyledRect {
        id: navButton

        required property var section
        property bool active: false

        signal clicked

        implicitHeight: navRow.implicitHeight + Tokens.padding.normal * 2
        color: active ? Colours.layer(Colours.palette.m3surfaceContainer, 2) : "transparent"
        radius: Tokens.rounding.normal

        Behavior on color {
            CAnim {}
        }

        StateLayer {
            onClicked: navButton.clicked()
        }

        RowLayout {
            id: navRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: navButton.section.icon
                fill: navButton.active ? 1 : 0
                color: navButton.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: navButton.section.title
                    font.weight: navButton.active ? 500 : 400
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                StyledText {
                    Layout.fillWidth: true
                    text: navButton.section.description
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.small
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: "chevron_right"
                opacity: navButton.active ? 1 : 0
                color: Colours.palette.m3primary
            }
        }
    }
}
