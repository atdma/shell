pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
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
    property string activeSection: "general"

    property bool enabled: Config.dashboard.enabled ?? true
    property bool showOnHover: Config.dashboard.showOnHover ?? true
    property int mediaUpdateInterval: GlobalConfig.dashboard.mediaUpdateInterval ?? 1000
    property int resourceUpdateInterval: GlobalConfig.dashboard.resourceUpdateInterval ?? 1000
    property int dragThreshold: Config.dashboard.dragThreshold ?? 50

    property bool showDashboard: Config.dashboard.showDashboard ?? true
    property bool showMedia: Config.dashboard.showMedia ?? true
    property bool showPerformance: Config.dashboard.showPerformance ?? true
    property bool showWeather: Config.dashboard.showWeather ?? true

    property bool showBattery: Config.dashboard.performance.showBattery ?? false
    property bool showGpu: Config.dashboard.performance.showGpu ?? true
    property bool showCpu: Config.dashboard.performance.showCpu ?? true
    property bool showMemory: Config.dashboard.performance.showMemory ?? true
    property bool showStorage: Config.dashboard.performance.showStorage ?? true
    property bool showNetwork: Config.dashboard.performance.showNetwork ?? true

    readonly property bool gpuAvailable: SystemUsage.gpuType !== "NONE"
    readonly property bool batteryAvailable: UPower.displayDevice.isLaptopBattery
    readonly property var sections: [
        {
            id: "general",
            title: qsTr("General"),
            description: qsTr("Visibility and timing"),
            icon: "dashboard"
        },
        {
            id: "tabs",
            title: qsTr("Tabs"),
            description: qsTr("Dashboard pages"),
            icon: "tab"
        },
        {
            id: "performance",
            title: qsTr("Performance"),
            description: qsTr("Resource cards"),
            icon: "monitoring"
        }
    ]

    function componentForSection(sectionId) {
        switch (sectionId) {
        case "tabs":
            return tabsComponent;
        case "performance":
            return performanceComponent;
        case "general":
        default:
            return generalComponent;
        }
    }

    function performanceOptions() {
        const options = [];

        if (root.batteryAvailable) {
            options.push({
                label: qsTr("Battery"),
                propertyName: "showBattery",
                onToggled: function (checked) {
                    root.showBattery = checked;
                    root.saveConfig();
                }
            });
        }

        if (root.gpuAvailable) {
            options.push({
                label: qsTr("GPU"),
                propertyName: "showGpu",
                onToggled: function (checked) {
                    root.showGpu = checked;
                    root.saveConfig();
                }
            });
        }

        options.push({
            label: qsTr("CPU"),
            propertyName: "showCpu",
            onToggled: function (checked) {
                root.showCpu = checked;
                root.saveConfig();
            }
        }, {
            label: qsTr("Memory"),
            propertyName: "showMemory",
            onToggled: function (checked) {
                root.showMemory = checked;
                root.saveConfig();
            }
        }, {
            label: qsTr("Storage"),
            propertyName: "showStorage",
            onToggled: function (checked) {
                root.showStorage = checked;
                root.saveConfig();
            }
        }, {
            label: qsTr("Network"),
            propertyName: "showNetwork",
            onToggled: function (checked) {
                root.showNetwork = checked;
                root.saveConfig();
            }
        });

        return options;
    }

    function saveConfig() {
        GlobalConfig.dashboard.enabled = root.enabled;
        GlobalConfig.dashboard.showOnHover = root.showOnHover;
        GlobalConfig.dashboard.mediaUpdateInterval = root.mediaUpdateInterval;
        GlobalConfig.dashboard.resourceUpdateInterval = root.resourceUpdateInterval;
        GlobalConfig.dashboard.dragThreshold = root.dragThreshold;
        GlobalConfig.dashboard.showDashboard = root.showDashboard;
        GlobalConfig.dashboard.showMedia = root.showMedia;
        GlobalConfig.dashboard.showPerformance = root.showPerformance;
        GlobalConfig.dashboard.showWeather = root.showWeather;
        GlobalConfig.dashboard.performance.showBattery = root.showBattery;
        GlobalConfig.dashboard.performance.showGpu = root.showGpu;
        GlobalConfig.dashboard.performance.showCpu = root.showCpu;
        GlobalConfig.dashboard.performance.showMemory = root.showMemory;
        GlobalConfig.dashboard.performance.showStorage = root.showStorage;
        GlobalConfig.dashboard.performance.showNetwork = root.showNetwork;
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
                            text: qsTr("Dashboard")
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
        id: generalComponent

        SectionPage {
            title: qsTr("General")
            subtitle: qsTr("Control dashboard visibility and interaction timing.")

            SectionContainer {
                Layout.fillWidth: true
                alignTop: true

                SwitchRow {
                    label: qsTr("Enabled")
                    checked: root.enabled
                    onToggled: checked => {
                        root.enabled = checked;
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
            }

            SectionContainer {
                Layout.fillWidth: true
                contentSpacing: Tokens.spacing.normal

                SliderInput {
                    Layout.fillWidth: true
                    label: qsTr("Media update interval")
                    value: root.mediaUpdateInterval
                    from: 100
                    to: 10000
                    stepSize: 100
                    suffix: "ms"
                    validator: IntValidator {
                        bottom: 100
                        top: 10000
                    }
                    formatValueFunction: val => Math.round(val).toString()
                    parseValueFunction: text => parseInt(text)
                    onValueModified: newValue => {
                        root.mediaUpdateInterval = Math.round(newValue);
                        root.saveConfig();
                    }
                }

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
        id: tabsComponent

        SectionPage {
            title: qsTr("Tabs")
            subtitle: qsTr("Choose which dashboard pages are available.")

            SectionContainer {
                Layout.fillWidth: true
                alignTop: true

                ConnectedButtonGroup {
                    rootItem: root
                    rows: 2
                    options: [
                        {
                            label: qsTr("Dashboard"),
                            propertyName: "showDashboard",
                            onToggled: function (checked) {
                                root.showDashboard = checked;
                                root.saveConfig();
                            }
                        },
                        {
                            label: qsTr("Media"),
                            propertyName: "showMedia",
                            onToggled: function (checked) {
                                root.showMedia = checked;
                                root.saveConfig();
                            }
                        },
                        {
                            label: qsTr("Performance"),
                            propertyName: "showPerformance",
                            onToggled: function (checked) {
                                root.showPerformance = checked;
                                root.saveConfig();
                            }
                        },
                        {
                            label: qsTr("Weather"),
                            propertyName: "showWeather",
                            onToggled: function (checked) {
                                root.showWeather = checked;
                                root.saveConfig();
                            }
                        }
                    ]
                }
            }
        }
    }

    Component {
        id: performanceComponent

        SectionPage {
            title: qsTr("Performance")
            subtitle: qsTr("Configure which resource cards the dashboard shows.")

            SectionContainer {
                Layout.fillWidth: true
                alignTop: true

                ConnectedButtonGroup {
                    rootItem: root
                    options: root.performanceOptions()
                }
            }

            SectionContainer {
                Layout.fillWidth: true
                contentSpacing: Tokens.spacing.normal

                SliderInput {
                    Layout.fillWidth: true
                    label: qsTr("Resource update interval")
                    value: root.resourceUpdateInterval
                    from: 100
                    to: 10000
                    stepSize: 100
                    suffix: "ms"
                    validator: IntValidator {
                        bottom: 100
                        top: 10000
                    }
                    formatValueFunction: val => Math.round(val).toString()
                    parseValueFunction: text => parseInt(text)
                    onValueModified: newValue => {
                        root.resourceUpdateInterval = Math.round(newValue);
                        root.saveConfig();
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
