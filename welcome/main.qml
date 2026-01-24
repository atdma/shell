import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: qsTr("Welcome to Caelestia")

    color: "#191114"

    Text {
        anchors.centerIn: parent
        text: "Welcome to Caelestia"
        font.pointSize: 28
        color: "#efdfe2"
    }
}
