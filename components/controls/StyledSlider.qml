import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Templates

Slider {
    id: root

    property bool showVU: false
    property real vuLevel: 0 // 0-1

    background: Item {
        // Filled portion (volume setting)
        StyledRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: root.implicitHeight / 3
            anchors.bottomMargin: root.implicitHeight / 3

            implicitWidth: root.handle.x - root.implicitHeight / 6

            color: Colours.palette.m3primary
            radius: Appearance.rounding.full
            topRightRadius: root.implicitHeight / 15
            bottomRightRadius: root.implicitHeight / 15
        }

        // Unfilled portion
        StyledRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: root.implicitHeight / 3
            anchors.bottomMargin: root.implicitHeight / 3

            implicitWidth: parent.width - root.handle.x - root.handle.implicitWidth - root.implicitHeight / 6

            color: Colours.palette.m3surfaceContainerHighest
            radius: Appearance.rounding.full
            topLeftRadius: root.implicitHeight / 15
            bottomLeftRadius: root.implicitHeight / 15
        }

        // VU meter overlay on top of the slider track
        StyledRect {
            id: vuMeter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: root.implicitHeight / 3
            anchors.bottomMargin: root.implicitHeight / 3

            property real targetWidth: root.showVU ? parent.width * Math.max(0, Math.min(1, root.vuLevel)) : 0
            property real previousWidth: 0
            property int animationDuration: 50
            property int easingType: Easing.OutQuad

            width: targetWidth
            visible: root.showVU && width > 0
            z: 1 // Layer above the slider track

            // Use secondary color for good visibility and design consistency
            color: Qt.rgba(
                Colours.palette.m3secondary.r,
                Colours.palette.m3secondary.g,
                Colours.palette.m3secondary.b,
                0.8
            )
            radius: Appearance.rounding.full
            topRightRadius: root.implicitHeight / 15
            bottomRightRadius: root.implicitHeight / 15

            onTargetWidthChanged: {
                const isRetracting = targetWidth < previousWidth;
                previousWidth = targetWidth;
                
                // Use different animation speeds for expanding vs retracting
                if (isRetracting) {
                    animationDuration = 200;
                    easingType = Easing.OutCubic;
                } else {
                    animationDuration = 50;
                    easingType = Easing.OutQuad;
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: vuMeter.animationDuration
                    easing.type: vuMeter.easingType
                }
            }
        }
    }

    handle: StyledRect {
        x: root.visualPosition * root.availableWidth - implicitWidth / 2

        implicitWidth: root.implicitHeight / 4.5
        implicitHeight: root.implicitHeight

        color: Colours.palette.m3primary
        radius: Appearance.rounding.full

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
