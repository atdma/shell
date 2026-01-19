import "../services"
import qs.components
import qs.config
import qs.services
import QtQuick

Item {
    id: root

    required property var modelData
    required property var list

    implicitHeight: Config.launcher.sizes.itemHeight
    readonly property color primaryText: Colours.on(Colours.palette.m3surface)

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

        MaterialIcon {
            id: icon

            text: "content_paste"
            font.pointSize: Appearance.font.size.extraLarge
            color: Qt.alpha(root.primaryText, 0.9)

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: icon.verticalCenter

            implicitWidth: parent.width - icon.width
            implicitHeight: name.implicitHeight + desc.implicitHeight

            StyledText {
                id: name

                text: root.modelData?.text ?? ""
                font.pointSize: Appearance.font.size.normal
                color: root.primaryText
                elide: Text.ElideRight
                width: root.width - icon.width - Appearance.rounding.normal * 2
            }

            StyledText {
                id: desc

                text: qsTr("Clipboard item %1").arg(root.modelData?.id ?? "")
                font.pointSize: Appearance.font.size.small
                color: Qt.alpha(root.primaryText, 0.7)

                elide: Text.ElideRight
                width: root.width - icon.width - Appearance.rounding.normal * 2

                anchors.top: name.bottom
            }
        }
    }
}
