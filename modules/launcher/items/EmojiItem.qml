import "../services"
import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property var modelData
    required property var list

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.normal

        function onClicked(): void {
            root.modelData?.onClicked(root.list);
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        StyledText {
            id: emoji

            text: root.modelData?.emoji ?? ""
            font.pointSize: Appearance.font.size.extraLarge
            font.family: "Noto Color Emoji"
            color: Colours.palette.m3onSurface

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: emoji.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: emoji.verticalCenter

            implicitWidth: parent.width - emoji.width
            implicitHeight: name.implicitHeight + desc.implicitHeight

            StyledText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
                color: Colours.palette.m3onSurface

                elide: Text.ElideRight
                width: root.width - emoji.width - Appearance.rounding.normal * 2
            }

            StyledText {
                id: desc

                text: root.modelData?.category ?? ""
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3onSurfaceVariant

                elide: Text.ElideRight
                width: root.width - emoji.width - Appearance.rounding.normal * 2

                anchors.top: name.bottom
            }
        }
    }
}
