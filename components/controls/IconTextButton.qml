import ".."
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    enum Type {
        Filled,
        Tonal,
        Text
    }

    property alias icon: iconLabel.text
    property alias text: label.text
    property bool checked
    property bool toggle
    property real horizontalPadding: Appearance.padding.normal
    property real verticalPadding: Appearance.padding.smaller
    property alias font: label.font
    property int type: IconTextButton.Filled
    readonly property real labelMaxWidth: Math.max(0, root.width - root.horizontalPadding * 2 - iconLabel.implicitWidth - rowContent.spacing)

    property alias stateLayer: stateLayer
    property alias iconLabel: iconLabel
    property alias label: label

    property bool internalChecked
    property color activeColour: type === IconTextButton.Filled ? Colours.palette.m3primary : Colours.palette.m3secondary
    property color inactiveColour: type === IconTextButton.Filled ? Colours.tPalette.m3surfaceContainer : Colours.palette.m3secondaryContainer
    property color activeOnColour: type === IconTextButton.Filled ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondary
    property color inactiveOnColour: type === IconTextButton.Filled ? Colours.palette.m3onSurface : Colours.palette.m3onSecondaryContainer

    signal clicked

    onCheckedChanged: internalChecked = checked

    radius: internalChecked ? Appearance.rounding.small : implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
    color: type === IconTextButton.Text ? "transparent" : internalChecked ? activeColour : inactiveColour

    implicitWidth: row.implicitWidth + horizontalPadding * 2
    implicitHeight: row.implicitHeight + verticalPadding * 2

    StateLayer {
        id: stateLayer

        color: root.internalChecked ? root.activeOnColour : root.inactiveOnColour

        function onClicked(): void {
            if (root.toggle)
                root.internalChecked = !root.internalChecked;
            root.clicked();
        }
    }

    RowLayout {
        id: row

        anchors.centerIn: parent
        width: Math.max(0, root.width - root.horizontalPadding * 2)
        height: Math.max(0, root.height - root.verticalPadding * 2)
        spacing: 0

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: rowContent

            spacing: Appearance.spacing.small

            MaterialIcon {
                id: iconLabel

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: Math.round(fontInfo.pointSize * 0.0575)
                color: root.internalChecked ? root.activeOnColour : root.inactiveOnColour
                fill: root.internalChecked ? 1 : 0

                Behavior on fill {
                    Anim {}
                }
            }

            StyledText {
                id: label

                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: -Math.round(iconLabel.fontInfo.pointSize * 0.0575)
                width: Math.min(implicitWidth, root.labelMaxWidth)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: root.internalChecked ? root.activeOnColour : root.inactiveOnColour
                autoFit: true
                minPointSize: Math.max(8, Math.round(font.pointSize * 0.7))
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }

    Behavior on radius {
        Anim {}
    }
}
