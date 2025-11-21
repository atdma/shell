pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    SplitPaneLayout {
        anchors.fill: parent

        leftContent: Component {

            StyledFlickable {
                id: leftAudioFlickable
                flickableDirection: Flickable.VerticalFlick
                contentHeight: leftContent.height

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: leftAudioFlickable
                }

                ColumnLayout {
                    id: leftContent

                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Appearance.spacing.normal

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.smaller

                    StyledText {
                        text: qsTr("Audio")
                        font.pointSize: Appearance.font.size.large
                        font.weight: 500
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                CollapsibleSection {
                    id: outputDevicesSection

                    Layout.fillWidth: true
                    title: qsTr("Output devices")
                    expanded: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            StyledText {
                                text: qsTr("Devices (%1)").arg(Audio.sinks.length)
                                font.pointSize: Appearance.font.size.normal
                                font.weight: 500
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("All available output devices")
                            color: Colours.palette.m3outline
                        }

                        Repeater {
                            Layout.fillWidth: true
                            model: Audio.sinks

                            delegate: StyledRect {
                                required property var modelData

                                Layout.fillWidth: true

                                color: Audio.sink?.id === modelData.id ? Colours.layer(Colours.palette.m3surfaceContainer, 2) : "transparent"
                                radius: Appearance.rounding.normal

                                StateLayer {
                                    function onClicked(): void {
                                        Audio.setAudioSink(modelData);
                                    }
                                }

                                RowLayout {
                                    id: outputRowLayout

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Appearance.padding.normal

                                    spacing: Appearance.spacing.normal

                                    MaterialIcon {
                                        text: Audio.sink?.id === modelData.id ? "speaker" : "speaker_group"
                                        font.pointSize: Appearance.font.size.large
                                        fill: Audio.sink?.id === modelData.id ? 1 : 0
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        maximumLineCount: 1

                                        text: modelData.description || qsTr("Unknown")
                                        font.weight: Audio.sink?.id === modelData.id ? 500 : 400
                                    }
                                }

                                implicitHeight: outputRowLayout.implicitHeight + Appearance.padding.normal * 2
                            }
                        }
                    }
                }

                CollapsibleSection {
                    id: inputDevicesSection

                    Layout.fillWidth: true
                    title: qsTr("Input devices")
                    expanded: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            StyledText {
                                text: qsTr("Devices (%1)").arg(Audio.sources.length)
                                font.pointSize: Appearance.font.size.normal
                                font.weight: 500
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("All available input devices")
                            color: Colours.palette.m3outline
                        }

                        Repeater {
                            Layout.fillWidth: true
                            model: Audio.sources

                            delegate: StyledRect {
                                required property var modelData

                                Layout.fillWidth: true

                                color: Audio.source?.id === modelData.id ? Colours.layer(Colours.palette.m3surfaceContainer, 2) : "transparent"
                                radius: Appearance.rounding.normal

                                StateLayer {
                                    function onClicked(): void {
                                        Audio.setAudioSource(modelData);
                                    }
                                }

                                RowLayout {
                                    id: inputRowLayout

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Appearance.padding.normal

                                    spacing: Appearance.spacing.normal

                                    MaterialIcon {
                                        text: "mic"
                                        font.pointSize: Appearance.font.size.large
                                        fill: Audio.source?.id === modelData.id ? 1 : 0
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        maximumLineCount: 1

                                        text: modelData.description || qsTr("Unknown")
                                        font.weight: Audio.source?.id === modelData.id ? 500 : 400
                                    }
                                }

                                implicitHeight: inputRowLayout.implicitHeight + Appearance.padding.normal * 2
                            }
                        }
                    }
                }
            }
        }
        }

        rightContent: Component {
            StyledFlickable {
                id: rightAudioFlickable
                flickableDirection: Flickable.VerticalFlick
                contentHeight: contentLayout.height

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: rightAudioFlickable
                }

                ColumnLayout {
                    id: contentLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: Appearance.spacing.normal

                        SettingsHeader {
                            icon: "volume_up"
                            title: qsTr("Audio Settings")
                        }

                        SwitchRow {
                            label: qsTr("Increase maximum volume")
                            checked: Config.services.allowVolumeOver100
                            onToggled: (checked) => {
                                Config.services.allowVolumeOver100 = checked;
                                
                                // Clamp volumes to 100% if toggle is turned off
                                if (!checked) {
                                    if (Audio.volume > 1.0) {
                                        Audio.setVolume(1.0);
                                    }
                                    if (Audio.sourceVolume > 1.0) {
                                        Audio.setSourceVolume(1.0);
                                    }
                                }
                            }
                        }

                        SectionHeader {
                            title: qsTr("Output volume")
                            description: qsTr("Control the volume of your output device")
                        }

                        SectionContainer {
                            contentSpacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Appearance.spacing.small

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Appearance.spacing.normal

                                    StyledText {
                                        text: qsTr("Volume")
                                        font.pointSize: Appearance.font.size.normal
                                        font.weight: 500
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    StyledInputField {
                                        id: outputVolumeInput
                                        Layout.preferredWidth: 70
                                        validator: IntValidator { 
                                            bottom: 0
                                            top: Config.services.allowVolumeOver100 ? 150 : 100
                                        }
                                        enabled: !Audio.muted
                                        
                                        Component.onCompleted: {
                                            text = Math.round(Audio.volume * 100).toString();
                                        }
                                        
                                        Connections {
                                            target: Audio
                                            function onVolumeChanged() {
                                                if (!outputVolumeInput.hasFocus) {
                                                    outputVolumeInput.text = Math.round(Audio.volume * 100).toString();
                                                }
                                            }
                                        }
                                        
                                        onTextEdited: (text) => {
                                            if (hasFocus) {
                                                const val = parseInt(text);
                                                const maxVal = Config.services.allowVolumeOver100 ? 150 : 100;
                                                if (!isNaN(val) && val >= 0 && val <= maxVal) {
                                                    Audio.setVolume(val / 100);
                                                }
                                            }
                                        }
                                        
                                        onEditingFinished: {
                                            const val = parseInt(text);
                                            const maxVal = Config.services.allowVolumeOver100 ? 150 : 100;
                                            if (isNaN(val) || val < 0 || val > maxVal) {
                                                text = Math.round(Audio.volume * 100).toString();
                                            }
                                        }
                                    }

                                    StyledText {
                                        text: "%"
                                        color: Colours.palette.m3outline
                                        font.pointSize: Appearance.font.size.normal
                                        opacity: Audio.muted ? 0.5 : 1
                                    }

                                    StyledRect {
                                        implicitWidth: implicitHeight
                                        implicitHeight: muteIcon.implicitHeight + Appearance.padding.normal * 2

                                        radius: Appearance.rounding.normal
                                        color: Audio.muted ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                                        StateLayer {
                                            function onClicked(): void {
                                                if (Audio.sink?.audio) {
                                                    Audio.sink.audio.muted = !Audio.sink.audio.muted;
                                                }
                                            }
                                        }

                                        MaterialIcon {
                                            id: muteIcon

                                            anchors.centerIn: parent
                                            text: Audio.muted ? "volume_off" : "volume_up"
                                            color: Audio.muted ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                                        }
                                    }
                                }

                                StyledSlider {
                                    id: outputVolumeSlider
                                    Layout.fillWidth: true
                                    implicitHeight: Appearance.padding.normal * 3

                                    from: 0
                                    to: Config.services.allowVolumeOver100 ? 1.5 : 1.0
                                    value: Audio.volume
                                    enabled: !Audio.muted
                                    opacity: enabled ? 1 : 0.5
                                    showVU: !Audio.muted
                                    vuLevel: {
                                        if (!Audio.cava.values || Audio.cava.values.length === 0) return 0;
                                        const max = Math.max(...Audio.cava.values);
                                        return Math.max(0, Math.min(1, max));
                                    }
                                    onMoved: {
                                        Audio.setVolume(value);
                                        if (!outputVolumeInput.hasFocus) {
                                            outputVolumeInput.text = Math.round(value * 100).toString();
                                        }
                                    }

                                    Behavior on to {
                                        NumberAnimation {
                                            duration: Appearance.anim.durations.normal
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }

                        SectionHeader {
                            title: qsTr("Input volume")
                            description: qsTr("Control the volume of your input device")
                        }

                        SectionContainer {
                            contentSpacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Appearance.spacing.small

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Appearance.spacing.normal

                                    StyledText {
                                        text: qsTr("Volume")
                                        font.pointSize: Appearance.font.size.normal
                                        font.weight: 500
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    StyledInputField {
                                        id: inputVolumeInput
                                        Layout.preferredWidth: 70
                                        validator: IntValidator { 
                                            bottom: 0
                                            top: Config.services.allowVolumeOver100 ? 150 : 100
                                        }
                                        enabled: !Audio.sourceMuted
                                        
                                        Component.onCompleted: {
                                            text = Math.round(Audio.sourceVolume * 100).toString();
                                        }
                                        
                                        Connections {
                                            target: Audio
                                                function onSourceVolumeChanged() {
                                                    if (!inputVolumeInput.hasFocus) {
                                                        inputVolumeInput.text = Math.round(Audio.sourceVolume * 100).toString();
                                                    }
                                                }
                                        }
                                        
                                        onTextEdited: (text) => {
                                            if (hasFocus) {
                                                const val = parseInt(text);
                                                const maxVal = Config.services.allowVolumeOver100 ? 150 : 100;
                                                if (!isNaN(val) && val >= 0 && val <= maxVal) {
                                                    Audio.setSourceVolume(val / 100);
                                                }
                                            }
                                        }
                                        
                                        onEditingFinished: {
                                            const val = parseInt(text);
                                            const maxVal = Config.services.allowVolumeOver100 ? 150 : 100;
                                            if (isNaN(val) || val < 0 || val > maxVal) {
                                                text = Math.round(Audio.sourceVolume * 100).toString();
                                            }
                                        }
                                    }

                                    StyledText {
                                        text: "%"
                                        color: Colours.palette.m3outline
                                        font.pointSize: Appearance.font.size.normal
                                        opacity: Audio.sourceMuted ? 0.5 : 1
                                    }

                                    StyledRect {
                                        implicitWidth: implicitHeight
                                        implicitHeight: muteInputIcon.implicitHeight + Appearance.padding.normal * 2

                                        radius: Appearance.rounding.normal
                                        color: Audio.sourceMuted ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                                        StateLayer {
                                            function onClicked(): void {
                                                if (Audio.source?.audio) {
                                                    Audio.source.audio.muted = !Audio.source.audio.muted;
                                                }
                                            }
                                        }

                                        MaterialIcon {
                                            id: muteInputIcon

                                            anchors.centerIn: parent
                                            text: "mic_off"
                                            color: Audio.sourceMuted ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                                        }
                                    }
                                }

                                StyledSlider {
                                    id: inputVolumeSlider
                                    Layout.fillWidth: true
                                    implicitHeight: Appearance.padding.normal * 3

                                    from: 0
                                    to: Config.services.allowVolumeOver100 ? 1.5 : 1.0
                                    value: Audio.sourceVolume
                                    enabled: !Audio.sourceMuted
                                    opacity: enabled ? 1 : 0.5
                                    showVU: !Audio.sourceMuted
                                    vuLevel: {
                                        // Input levels aren't available via cava, so we'll show a minimal indicator
                                        // when input is active (you could enhance this later with input-specific monitoring)
                                        return 0;
                                    }
                                    onMoved: {
                                        Audio.setSourceVolume(value);
                                        if (!inputVolumeInput.hasFocus) {
                                            inputVolumeInput.text = Math.round(value * 100).toString();
                                        }
                                    }

                                    Behavior on to {
                                        NumberAnimation {
                                            duration: Appearance.anim.durations.normal
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }

                        SectionHeader {
                            title: qsTr("Applications")
                            description: qsTr("Control volume for individual applications")
                        }

                        SectionContainer {
                            contentSpacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Appearance.spacing.normal

                                Repeater {
                                    model: Audio.streams

                                    delegate: ColumnLayout {
                                        required property var modelData
                                        required property int index

                                        Layout.fillWidth: true
                                        spacing: Appearance.spacing.small

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Appearance.spacing.normal

                                            StyledText {
                                                Layout.fillWidth: true
                                                text: {
                                                    if (modelData.description) return modelData.description;
                                                    if (modelData.name) return modelData.name;
                                                    return qsTr("Unknown Application");
                                                }
                                                font.pointSize: Appearance.font.size.normal
                                                font.weight: 500
                                                elide: Text.ElideRight
                                            }

                                            StyledInputField {
                                                id: streamVolumeInput
                                                Layout.preferredWidth: 70
                                                validator: IntValidator { 
                                                    bottom: 0
                                                    top: Config.services.allowVolumeOver100 ? 150 : 100
                                                }
                                                enabled: modelData.ready && modelData.audio && !modelData.audio.muted
                                                
                                                property real streamVolume: modelData.ready && modelData.audio ? (modelData.audio.volume ?? 0) : 0
                                                
                                                Component.onCompleted: {
                                                    text = Math.round(streamVolume * 100).toString();
                                                }
                                                
                                                onStreamVolumeChanged: {
                                                    if (!hasFocus) {
                                                        text = Math.round(streamVolume * 100).toString();
                                                    }
                                                }
                                                
                                                onTextEdited: (text) => {
                                                    if (hasFocus && modelData.ready && modelData.audio) {
                                                        const val = parseInt(text);
                                                        const maxVal = Config.services.allowVolumeOver100 ? 150 : 100;
                                                        if (!isNaN(val) && val >= 0 && val <= maxVal) {
                                                            Audio.setStreamVolume(modelData, val / 100);
                                                        }
                                                    }
                                                }
                                                
                                                onEditingFinished: {
                                                    if (modelData.ready && modelData.audio) {
                                                        const val = parseInt(text);
                                                        const maxVal = Config.services.allowVolumeOver100 ? 150 : 100;
                                                        if (isNaN(val) || val < 0 || val > maxVal) {
                                                            text = Math.round(streamVolume * 100).toString();
                                                        }
                                                    }
                                                }
                                            }

                                            StyledText {
                                                text: "%"
                                                color: Colours.palette.m3outline
                                                font.pointSize: Appearance.font.size.normal
                                                opacity: (modelData.ready && modelData.audio && modelData.audio.muted) ? 0.5 : 1
                                            }

                                            StyledRect {
                                                implicitWidth: implicitHeight
                                                implicitHeight: streamMuteIcon.implicitHeight + Appearance.padding.normal * 2

                                                radius: Appearance.rounding.normal
                                                property bool isMuted: modelData.ready && modelData.audio && modelData.audio.muted
                                                color: isMuted ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                                                StateLayer {
                                                    function onClicked(): void {
                                                        if (modelData.ready && modelData.audio) {
                                                            Audio.setStreamMuted(modelData, !modelData.audio.muted);
                                                        }
                                                    }
                                                }

                                                MaterialIcon {
                                                    id: streamMuteIcon

                                                    anchors.centerIn: parent
                                                    text: parent.isMuted ? "volume_off" : "volume_up"
                                                    color: parent.isMuted ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                                                }
                                            }
                                        }

                                        StyledSlider {
                                            id: streamVolumeSlider
                                            Layout.fillWidth: true
                                            implicitHeight: Appearance.padding.normal * 3

                                            from: 0
                                            to: Config.services.allowVolumeOver100 ? 1.5 : 1.0
                                            value: modelData.ready && modelData.audio ? (modelData.audio.volume ?? 0) : 0
                                            enabled: modelData.ready && modelData.audio && !modelData.audio.muted
                                            opacity: enabled ? 1 : 0.5
                                            
                                            onMoved: {
                                                if (modelData.ready && modelData.audio) {
                                                    Audio.setStreamVolume(modelData, value);
                                                    if (!streamVolumeInput.hasFocus) {
                                                        streamVolumeInput.text = Math.round(value * 100).toString();
                                                    }
                                                }
                                            }

                                            Behavior on to {
                                                NumberAnimation {
                                                    duration: Appearance.anim.durations.normal
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }
                                }

                                StyledText {
                                    visible: Audio.streams.length === 0
                                    Layout.fillWidth: true
                                    text: qsTr("No applications are currently playing audio")
                                    color: Colours.palette.m3outline
                                    font.pointSize: Appearance.font.size.normal
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }