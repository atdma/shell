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

Item {
    id: root

    required property Session session
    property string activeSection: "notifications"

    property bool notificationsExpire: GlobalConfig.notifs.expire ?? true
    property string notificationsFullscreen: GlobalConfig.notifs.fullscreen ?? "on"
    property bool notificationsOpenExpanded: Config.notifs.openExpanded ?? false
    property int notificationsDefaultExpireTimeout: GlobalConfig.notifs.defaultExpireTimeout ?? 5000
    property int notificationsGroupPreviewNum: Config.notifs.groupPreviewNum ?? 3

    property int maxToasts: Config.utilities.maxToasts ?? 4
    property string toastsFullscreen: Config.utilities.toasts.fullscreen ?? "off"
    property bool chargingChanged: GlobalConfig.utilities.toasts.chargingChanged ?? true
    property bool gameModeChanged: GlobalConfig.utilities.toasts.gameModeChanged ?? true
    property bool dndChanged: GlobalConfig.utilities.toasts.dndChanged ?? true
    property bool audioOutputChanged: GlobalConfig.utilities.toasts.audioOutputChanged ?? true
    property bool audioInputChanged: GlobalConfig.utilities.toasts.audioInputChanged ?? true
    property bool capsLockChanged: GlobalConfig.utilities.toasts.capsLockChanged ?? true
    property bool numLockChanged: GlobalConfig.utilities.toasts.numLockChanged ?? true
    property bool kbLayoutChanged: GlobalConfig.utilities.toasts.kbLayoutChanged ?? true
    property bool vpnChanged: GlobalConfig.utilities.toasts.vpnChanged ?? true
    property bool nowPlaying: GlobalConfig.utilities.toasts.nowPlaying ?? false

    readonly property var sections: [
        {
            id: "notifications",
            title: qsTr("Notifications"),
            description: qsTr("Popup behavior"),
            icon: "notifications"
        },
        {
            id: "toastSettings",
            title: qsTr("Toast Settings"),
            description: qsTr("Toast visibility"),
            icon: "toast"
        },
        {
            id: "toastEvents",
            title: qsTr("Toast Events"),
            description: qsTr("Event triggers"),
            icon: "rule"
        }
    ]

    function componentForSection(sectionId) {
        switch (sectionId) {
        case "toastSettings":
            return toastSettingsComponent;
        case "toastEvents":
            return toastEventsComponent;
        case "notifications":
        default:
            return notificationsComponent;
        }
    }

    function saveConfig(): void {
        GlobalConfig.notifs.expire = root.notificationsExpire;
        GlobalConfig.notifs.fullscreen = root.notificationsFullscreen;
        GlobalConfig.notifs.openExpanded = root.notificationsOpenExpanded;
        GlobalConfig.notifs.defaultExpireTimeout = root.notificationsDefaultExpireTimeout;
        GlobalConfig.notifs.groupPreviewNum = root.notificationsGroupPreviewNum;

        GlobalConfig.utilities.maxToasts = root.maxToasts;
        GlobalConfig.utilities.toasts.fullscreen = root.toastsFullscreen;
        GlobalConfig.utilities.toasts.chargingChanged = root.chargingChanged;
        GlobalConfig.utilities.toasts.gameModeChanged = root.gameModeChanged;
        GlobalConfig.utilities.toasts.dndChanged = root.dndChanged;
        GlobalConfig.utilities.toasts.audioOutputChanged = root.audioOutputChanged;
        GlobalConfig.utilities.toasts.audioInputChanged = root.audioInputChanged;
        GlobalConfig.utilities.toasts.capsLockChanged = root.capsLockChanged;
        GlobalConfig.utilities.toasts.numLockChanged = root.numLockChanged;
        GlobalConfig.utilities.toasts.kbLayoutChanged = root.kbLayoutChanged;
        GlobalConfig.utilities.toasts.vpnChanged = root.vpnChanged;
        GlobalConfig.utilities.toasts.nowPlaying = root.nowPlaying;
    }

    anchors.fill: parent

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
                            text: qsTr("Notifications")
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

    Component {
        id: notificationsComponent

        SectionPage {
            title: qsTr("Notifications")
            subtitle: qsTr("Configure notification popup behavior.")

            SectionContainer {
                Layout.fillWidth: true
                alignTop: true

                SplitButtonRow {
                    id: notificationsFullscreenSelector

                    function syncActiveItem(): void {
                        active = root.notificationsFullscreen === "off" ? notificationsFullscreenOffItem : notificationsFullscreenOnItem;
                    }

                    label: qsTr("Show in fullscreen")
                    menuItems: [notificationsFullscreenOffItem, notificationsFullscreenOnItem]

                    Component.onCompleted: syncActiveItem()

                    Connections {
                        function onNotificationsFullscreenChanged(): void {
                            notificationsFullscreenSelector.syncActiveItem();
                        }

                        target: root
                    }

                    MenuItem {
                        id: notificationsFullscreenOffItem

                        text: qsTr("Off")
                        icon: "notifications_off"
                        activeText: qsTr("Off")
                        onClicked: {
                            root.notificationsFullscreen = "off";
                            root.saveConfig();
                        }
                    }

                    MenuItem {
                        id: notificationsFullscreenOnItem

                        text: qsTr("On")
                        icon: "notifications"
                        activeText: qsTr("On")
                        onClicked: {
                            root.notificationsFullscreen = "on";
                            root.saveConfig();
                        }
                    }
                }

                SwitchRow {
                    label: qsTr("Expire automatically")
                    checked: root.notificationsExpire
                    onToggled: checked => {
                        root.notificationsExpire = checked;
                        root.saveConfig();
                    }
                }

                SwitchRow {
                    label: qsTr("Open expanded")
                    checked: root.notificationsOpenExpanded
                    onToggled: checked => {
                        root.notificationsOpenExpanded = checked;
                        root.saveConfig();
                    }
                }

                SpinBoxRow {
                    label: qsTr("Default timeout")
                    value: root.notificationsDefaultExpireTimeout
                    min: 1000
                    max: 60000
                    step: 500
                    onValueModified: value => {
                        root.notificationsDefaultExpireTimeout = value;
                        root.saveConfig();
                    }
                }

                SpinBoxRow {
                    label: qsTr("Group preview count")
                    value: root.notificationsGroupPreviewNum
                    min: 1
                    max: 10
                    step: 1
                    onValueModified: value => {
                        root.notificationsGroupPreviewNum = value;
                        root.saveConfig();
                    }
                }
            }
        }
    }

    Component {
        id: toastSettingsComponent

        SectionPage {
            title: qsTr("Toast Settings")
            subtitle: qsTr("Control when toast notifications are shown.")

            SectionContainer {
                Layout.fillWidth: true
                alignTop: true

                SplitButtonRow {
                    id: toastFullscreenSelector

                    function syncActiveItem(): void {
                        if (root.toastsFullscreen === "all") {
                            active = toastFullscreenAllItem;
                            return;
                        }

                        if (root.toastsFullscreen === "important") {
                            active = toastFullscreenImportantItem;
                            return;
                        }

                        active = toastFullscreenOffItem;
                    }

                    Layout.fillWidth: true
                    z: expanded ? 100 : 0
                    label: qsTr("Show in fullscreen")
                    menuItems: [toastFullscreenOffItem, toastFullscreenImportantItem, toastFullscreenAllItem]

                    Component.onCompleted: syncActiveItem()
                    Connections {
                        function onToastsFullscreenChanged(): void {
                            toastFullscreenSelector.syncActiveItem();
                        }

                        target: root
                    }

                    MenuItem {
                        id: toastFullscreenOffItem
                        text: qsTr("Off")
                        icon: "notifications_off"
                        activeText: qsTr("Off")
                        onClicked: {
                            root.toastsFullscreen = "off";
                            root.saveConfig();
                        }
                    }

                    MenuItem {
                        id: toastFullscreenImportantItem
                        text: qsTr("Important")
                        icon: "priority_high"
                        activeText: qsTr("Important")
                        onClicked: {
                            root.toastsFullscreen = "important";
                            root.saveConfig();
                        }
                    }

                    MenuItem {
                        id: toastFullscreenAllItem
                        text: qsTr("On")
                        icon: "notifications"
                        activeText: qsTr("On")
                        onClicked: {
                            root.toastsFullscreen = "all";
                            root.saveConfig();
                        }
                    }
                }

                SpinBoxRow {
                    Layout.fillWidth: true
                    label: qsTr("Visible toasts")
                    value: root.maxToasts
                    min: 1
                    max: 10
                    step: 1
                    onValueModified: value => {
                        root.maxToasts = value;
                        root.saveConfig();
                    }
                }
            }
        }
    }

    Component {
        id: toastEventsComponent

        SectionPage {
            title: qsTr("Toast Events")
            subtitle: qsTr("Choose which system events create toasts.")

            SectionContainer {
                Layout.fillWidth: true
                alignTop: true

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Tokens.spacing.normal
                    rowSpacing: Tokens.spacing.normal

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Charging changes")
                        checked: root.chargingChanged
                        onToggled: checked => {
                            root.chargingChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Game mode changes")
                        checked: root.gameModeChanged
                        onToggled: checked => {
                            root.gameModeChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Do not disturb")
                        checked: root.dndChanged
                        onToggled: checked => {
                            root.dndChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Audio output changes")
                        checked: root.audioOutputChanged
                        onToggled: checked => {
                            root.audioOutputChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Audio input changes")
                        checked: root.audioInputChanged
                        onToggled: checked => {
                            root.audioInputChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Caps lock changes")
                        checked: root.capsLockChanged
                        onToggled: checked => {
                            root.capsLockChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Num lock changes")
                        checked: root.numLockChanged
                        onToggled: checked => {
                            root.numLockChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Keyboard layout changes")
                        checked: root.kbLayoutChanged
                        onToggled: checked => {
                            root.kbLayoutChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("VPN changes")
                        checked: root.vpnChanged
                        onToggled: checked => {
                            root.vpnChanged = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        label: qsTr("Now playing")
                        checked: root.nowPlaying
                        onToggled: checked => {
                            root.nowPlaying = checked;
                            root.saveConfig();
                        }
                    }
                }
            }
        }
    }

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
