import "../services"
import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property var modelData
    required property var list

    implicitWidth: width
    implicitHeight: height

    StateLayer {
        radius: Appearance.rounding.normal

        function onClicked(): void {
            root.modelData?.onClicked(root.list);
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Appearance.padding.small
        spacing: Appearance.spacing.smaller

        StyledText {
            id: emoji

            text: root.modelData?.emoji ?? ""
            font.pointSize: Appearance.font.size.extraLarge
            font.family: "Noto Color Emoji"
            color: Colours.palette.m3onSurface
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        StyledText {
            id: name

            text: root.modelData?.name ?? ""
            font.pointSize: Appearance.font.size.small
            color: Colours.palette.m3onSurface
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            width: parent.width
        }

        StyledText {
            id: category

            text: root.modelData?.category ?? ""
            font.pointSize: Appearance.font.size.small
            color: Colours.palette.m3onSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            width: parent.width
        }
    }
}
