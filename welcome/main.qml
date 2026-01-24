import QtQuick
import QtQuick.Controls
import caelestia.welcome 1.0

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: qsTr("Welcome to Caelestia")

    color: Colours.palette.m3background

    Text {
        anchors.centerIn: parent
        text: "Welcome to Caelestia"
        font.pointSize: 28
        color: Colours.palette.m3onBackground
    }
}
