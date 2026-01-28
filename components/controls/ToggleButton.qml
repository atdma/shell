import ".."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property bool toggled
    property string icon
    property string label
    property string accent: "Secondary"
    property real iconSize: Appearance.font.size.large
    property real horizontalPadding: Appearance.padding.large
    property real verticalPadding: Appearance.padding.normal
    property string tooltip: ""
    readonly property bool hasLabel: root.label !== ""
    readonly property real labelMaxWidth: Math.max(0, root.width - root.horizontalPadding * 2 - toggleBtnIcon.implicitWidth - (hasLabel ? toggleBtnContent.spacing : 0))

    property bool hovered: false
    signal clicked

    Component.onCompleted: {
        hovered = toggleStateLayer.containsMouse;
    }

    Connections {
        target: toggleStateLayer
        function onContainsMouseChanged() {
            const newHovered = toggleStateLayer.containsMouse;
            if (hovered !== newHovered) {
                hovered = newHovered;
            }
        }
    }

    Layout.preferredWidth: implicitWidth + (toggleStateLayer.pressed ? Appearance.padding.normal * 2 : toggled ? Appearance.padding.small * 2 : 0)
    implicitWidth: toggleBtnInner.implicitWidth + horizontalPadding * 2
    implicitHeight: toggleBtnIcon.implicitHeight + verticalPadding * 2

    radius: toggled || toggleStateLayer.pressed ? Appearance.rounding.small : Math.min(width, height) / 2 * Math.min(1, Appearance.rounding.scale)
    color: toggled ? Colours.palette[`m3${accent.toLowerCase()}`] : Colours.palette[`m3${accent.toLowerCase()}Container`]

    StateLayer {
        id: toggleStateLayer

        color: root.toggled ? Colours.palette[`m3on${root.accent}`] : Colours.palette[`m3on${root.accent}Container`]

        function onClicked(): void {
            root.clicked();
        }
    }

    RowLayout {
        id: toggleBtnInner

        anchors.centerIn: parent
        width: Math.max(0, root.width - root.horizontalPadding * 2)
        height: Math.max(0, root.height - root.verticalPadding * 2)
        spacing: 0

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: toggleBtnContent

            spacing: root.hasLabel ? Appearance.spacing.normal : 0

            MaterialIcon {
                id: toggleBtnIcon

                visible: !!text
                fill: root.toggled ? 1 : 0
                text: root.icon
                color: root.toggled ? Colours.palette[`m3on${root.accent}`] : Colours.palette[`m3on${root.accent}Container`]
                font.pointSize: root.iconSize

                Behavior on fill {
                    Anim {}
                }
            }

            Loader {
                active: root.hasLabel
                visible: active
                Layout.minimumWidth: 0

                sourceComponent: StyledText {
                    width: Math.min(implicitWidth, root.labelMaxWidth)
                    height: parent ? parent.height : implicitHeight
                    text: root.label
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: root.toggled ? Colours.palette[`m3on${root.accent}`] : Colours.palette[`m3on${root.accent}Container`]
                    autoFit: true
                    minPointSize: Math.max(8, Math.round(font.pointSize * 0.7))
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }

    Behavior on radius {
        Anim {
            duration: Appearance.anim.durations.expressiveFastSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
        }
    }

    Behavior on Layout.preferredWidth {
        Anim {
            duration: Appearance.anim.durations.expressiveFastSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
        }
    }

    // Tooltip - positioned absolutely, doesn't affect layout
    Loader {
        id: tooltipLoader
        active: root.tooltip !== ""
        z: 10000
        width: 0
        height: 0
        sourceComponent: Component {
            Tooltip {
                target: root
                text: root.tooltip
            }
        }
        // Completely remove from layout
        Layout.fillWidth: false
        Layout.fillHeight: false
        Layout.preferredWidth: 0
        Layout.preferredHeight: 0
        Layout.maximumWidth: 0
        Layout.maximumHeight: 0
        Layout.minimumWidth: 0
        Layout.minimumHeight: 0
    }
}
