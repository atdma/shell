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
    property string activeSection: "general"

    // General Settings
    property bool enabled: Config.dashboard.enabled ?? true
    property bool showOnHover: Config.dashboard.showOnHover ?? true
    property int mediaUpdateInterval: GlobalConfig.dashboard.mediaUpdateInterval ?? 1000
    property int resourceUpdateInterval: GlobalConfig.dashboard.resourceUpdateInterval ?? 1000
    property int dragThreshold: Config.dashboard.dragThreshold ?? 50

    // Dashboard Tabs
    property bool showDashboard: Config.dashboard.showDashboard ?? true
    property bool showMedia: Config.dashboard.showMedia ?? true
    property bool showPerformance: Config.dashboard.showPerformance ?? true
    property bool showWeather: Config.dashboard.showWeather ?? true

    // Performance Resources
    property bool showBattery: Config.dashboard.performance.showBattery ?? false
    property bool showGpu: Config.dashboard.performance.showGpu ?? true
    property bool showCpu: Config.dashboard.performance.showCpu ?? true
    property bool showMemory: Config.dashboard.performance.showMemory ?? true
    property bool showStorage: Config.dashboard.performance.showStorage ?? true
    property bool showNetwork: Config.dashboard.performance.showNetwork ?? true

    readonly property var sections: [
        {
            id: "general",
            title: qsTr("General Settings"),
            description: qsTr("Tabs and behavior"),
            icon: "settings"
        },
        {
            id: "performance",
            title: qsTr("Performance Resources"),
            description: qsTr("Resource monitoring"),
            icon: "monitoring"
        }
    ]

    function componentForSection(sectionId) {
        switch (sectionId) {
        case "performance":
            return performanceComponent;
        case "general":
        default:
            return generalComponent;
        }
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

        StyledFlickable {
            id: generalFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: generalLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: generalFlickable
            }

            ColumnLayout {
                id: generalLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Tokens.spacing.normal

                GeneralSection {
                    rootItem: root
                }
            }
        }
    }

    Component {
        id: performanceComponent

        StyledFlickable {
            id: performanceFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: performanceLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: performanceFlickable
            }

            ColumnLayout {
                id: performanceLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Tokens.spacing.normal

                PerformanceSection {
                    rootItem: root
                }
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
