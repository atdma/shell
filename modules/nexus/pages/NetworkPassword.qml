pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property Nmcli.AccessPoint ap: nState.selectedNetwork

    title: ap?.ssid ?? qsTr("Connect to Network")
    isSubPage: true

    onApChanged: {
        if (!ap) {
            nState.closeSubPage();
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.large

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall

            StyledText {
                text: qsTr("Enter password for \"%1\"").arg(ap?.ssid ?? "")
                font: Tokens.font.body.medium
            }

            StyledText {
                text: qsTr("Security: %1").arg(ap?.security ?? "")
                color: Colours.palette.m3outline
                font: Tokens.font.body.small
            }
        }

        // Status or Error text
        StyledText {
            id: errorText
            Layout.fillWidth: true
            visible: text !== ""
            text: ""
            color: Colours.palette.m3error
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 48
            radius: Tokens.rounding.medium
            color: passwordInput.activeFocus ? Colours.layer(Colours.palette.m3surfaceContainer, 3) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
            border.width: 1
            border.color: passwordInput.activeFocus ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.3)

            StyledTextField {
                id: passwordInput
                anchors.centerIn: parent
                width: parent.width - Tokens.padding.medium * 2
                placeholderText: qsTr("Password")
                echoMode: TextField.Password
                focus: true

                onAccepted: {
                    if (connectButton.enabled) {
                        connectButton.clicked();
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            TextButton {
                Layout.fillWidth: true
                Layout.minimumHeight: 40
                inactiveColour: Colours.palette.m3secondaryContainer
                inactiveOnColour: Colours.palette.m3onSecondaryContainer
                text: qsTr("Cancel")
                onClicked: nState.closeSubPage()
            }

            TextButton {
                id: connectButton
                property bool connecting: false

                Layout.fillWidth: true
                Layout.minimumHeight: 40
                inactiveColour: Colours.palette.m3primary
                inactiveOnColour: Colours.palette.m3onPrimary
                text: connecting ? qsTr("Connecting...") : qsTr("Connect")
                enabled: passwordInput.text.length > 0 && !connecting

                onClicked: {
                    if (!ap || connecting) return;

                    connecting = true;
                    errorText.text = "";

                    NetworkConnection.connectWithPassword(ap, passwordInput.text, result => {
                        connecting = false;
                        if (result && result.success) {
                            nState.closeSubPage();
                        } else {
                            errorText.text = qsTr("Failed to connect. Please check the password.");
                            passwordInput.text = "";
                        }
                    });
                }
            }
        }
    }
}
