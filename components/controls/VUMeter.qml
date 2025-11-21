import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    property real level: 0 // 0-1
    property color color: Colours.palette.m3primary

    implicitHeight: 4
    implicitWidth: 200

    StyledRect {
        anchors.fill: parent
        color: Colours.palette.m3surfaceContainerHighest
        radius: Appearance.rounding.full
    }

    StyledRect {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * Math.max(0, Math.min(1, root.level))
        color: root.color
        radius: Appearance.rounding.full

        Behavior on width {
            NumberAnimation {
                duration: 50
                easing.type: Easing.OutQuad
            }
        }
    }
}

