pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property var props
    required property var visibilities

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + layout.anchors.margins * 2

    radius: Appearance.rounding.normal
    color: Colours.tPalette.m3surfaceContainer

    property bool actuallyRecording: Recorder.running
    property string lastError: ""
    property string currentVideoMode: Config.utilities.recording.videoMode

    // Computed audio mode based on settings
    readonly property string currentAudioMode: {
        const recordSystem = Config.utilities.recording.recordSystem;
        const recordMic = Config.utilities.recording.recordMicrophone;
        if (recordSystem && recordMic) return "combined";
        if (recordSystem) return "system";
        if (recordMic) return "mic";
        return "none";
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        RowLayout {
            spacing: Appearance.spacing.normal
            z: 1

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: {
                    const h = icon.implicitHeight + Appearance.padding.smaller * 2;
                    return h - (h % 2);
                }

                radius: Appearance.rounding.full
                color: root.actuallyRecording ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    id: icon

                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: -0.5
                    anchors.verticalCenterOffset: 1.5
                    text: "screen_record"
                    color: root.actuallyRecording ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Screen Recorder")
                    font.pointSize: Appearance.font.size.normal
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        if (root.lastError !== "") return qsTr("Error: %1").arg(root.lastError);
                        if (Recorder.paused) return qsTr("Recording paused");
                        if (root.actuallyRecording) {
                            const videoText = root.currentVideoMode;
                            const audioText = root.currentAudioMode === "none" ? "no audio" : root.currentAudioMode;
                            return qsTr("Recording %1 - %2").arg(videoText).arg(audioText);
                        }
                        return qsTr("Recording off");
                    }
                    color: root.lastError !== "" ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }
            }

            SplitButton {
                disabled: root.actuallyRecording
                active: menuItems.find(m => m.mode === Config.utilities.recording.videoMode) ?? menuItems[0]
                menu.onItemSelected: item => {
                    Config.utilities.recording.videoMode = item.mode;
                    root.currentVideoMode = item.mode;
                    Config.save();
                }

                menuItems: [
                    MenuItem {
                        property string mode: "fullscreen"
                        icon: "fullscreen"
                        text: qsTr("Record fullscreen")
                        activeText: qsTr("Fullscreen")
                        onClicked: startRecording()
                    },
                    MenuItem {
                        property string mode: "region"
                        icon: "screenshot_region"
                        text: qsTr("Record region")
                        activeText: qsTr("Region")
                        onClicked: startRecording()
                    },
                    MenuItem {
                        property string mode: "window"
                        icon: "web_asset"
                        text: qsTr("Record window")
                        activeText: qsTr("Window")
                        onClicked: startRecording()
                    }
                ]
            }
        }

        StyledRect {
            id: errorBanner
            Layout.fillWidth: true
            visible: root.lastError !== ""
            implicitHeight: visible ? errorText.implicitHeight + Appearance.padding.normal * 2 : 0
            radius: Appearance.rounding.small
            color: Colours.palette.m3errorContainer

            StyledText {
                id: errorText
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                text: root.lastError
                color: Colours.palette.m3onErrorContainer
                wrapMode: Text.Wrap
                font.pointSize: Appearance.font.size.small
            }

            Behavior on implicitHeight {
                Anim { duration: Appearance.anim.durations.small }
            }
        }

        // Audio Sources Section
        ColumnLayout {
            Layout.fillWidth: true
            visible: !root.actuallyRecording
            spacing: Appearance.spacing.small

            RowLayout {
                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("Audio Sources")
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                }

                Item { Layout.fillWidth: true }

                IconButton {
                    icon: root.props.recordingAudioExpanded ? "expand_less" : "expand_more"
                    type: IconButton.Tonal
                    font.pointSize: Appearance.font.size.small
                    onClicked: {
                        root.props.recordingAudioExpanded = !root.props.recordingAudioExpanded;
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: root.props.recordingAudioExpanded
                spacing: Appearance.spacing.smaller

                // System Audio (Default Sink)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.normal

                    StyledSwitch {
                        checked: Config.utilities.recording.recordSystem
                        onToggled: {
                            Config.utilities.recording.recordSystem = checked;
                            Config.save();
                        }
                    }

                    StyledText {
                        Layout.preferredWidth: 85
                        text: qsTr("System")
                        font.pointSize: Appearance.font.size.small
                        elide: Text.ElideRight
                    }

                    StyledSlider {
                        id: systemVolumeSlider
                        Layout.fillWidth: true
                        implicitHeight: 24
                        opacity: Config.utilities.recording.recordSystem ? 1.0 : 0.5
                        from: 0
                        to: 1
                        value: Audio.volume
                        onMoved: {
                            Audio.setVolume(value);
                        }
                    }

                    StyledText {
                        text: Math.round(Audio.volume * 100) + "%"
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3onSurfaceVariant
                        Layout.preferredWidth: 40
                    }

                    IconButton {
                        icon: Audio.muted ? "volume_off" : "volume_up"
                        type: Audio.muted ? IconButton.Filled : IconButton.Tonal
                        font.pointSize: Appearance.font.size.small
                        onClicked: {
                            if (Audio.sink?.audio) {
                                Audio.sink.audio.muted = !Audio.sink.audio.muted;
                            }
                        }
                    }
                }

                // Microphone (Default Source)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.normal

                    StyledSwitch {
                        checked: Config.utilities.recording.recordMicrophone
                        onToggled: {
                            Config.utilities.recording.recordMicrophone = checked;
                            Config.save();
                        }
                    }

                    StyledText {
                        Layout.preferredWidth: 85
                        text: qsTr("Microphone")
                        font.pointSize: Appearance.font.size.small
                        elide: Text.ElideRight
                    }

                    StyledSlider {
                        id: micVolumeSlider
                        Layout.fillWidth: true
                        implicitHeight: 24
                        opacity: Config.utilities.recording.recordMicrophone ? 1.0 : 0.5
                        from: 0
                        to: 1
                        value: Audio.sourceVolume
                        onMoved: {
                            Audio.setSourceVolume(value);
                        }
                    }

                    StyledText {
                        text: Math.round(Audio.sourceVolume * 100) + "%"
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3onSurfaceVariant
                        Layout.preferredWidth: 40
                    }

                    IconButton {
                        icon: Audio.sourceMuted ? "mic_off" : "mic"
                        type: Audio.sourceMuted ? IconButton.Filled : IconButton.Tonal
                        font.pointSize: Appearance.font.size.small
                        onClicked: {
                            if (Audio.source?.audio) {
                                Audio.source.audio.muted = !Audio.source.audio.muted;
                            }
                        }
                    }
                }
            }
        }

        Loader {
            id: listOrControls

            property bool running: root.actuallyRecording

            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            sourceComponent: running ? recordingControls : recordingList

            Behavior on Layout.preferredHeight {
                id: locHeightAnim
                enabled: false
                Anim {}
            }

            Behavior on running {
                SequentialAnimation {
                    ParallelAnimation {
                        Anim {
                            target: listOrControls
                            property: "scale"
                            to: 0.7
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardAccel
                        }
                        Anim {
                            target: listOrControls
                            property: "opacity"
                            to: 0
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardAccel
                        }
                    }
                    PropertyAction {
                        target: locHeightAnim
                        property: "enabled"
                        value: true
                    }
                    PropertyAction {}
                    PropertyAction {
                        target: locHeightAnim
                        property: "enabled"
                        value: false
                    }
                    ParallelAnimation {
                        Anim {
                            target: listOrControls
                            property: "scale"
                            to: 1
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardDecel
                        }
                        Anim {
                            target: listOrControls
                            property: "opacity"
                            to: 1
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardDecel
                        }
                    }
                }
            }
        }
    }

    Component {
        id: recordingList
        RecordingList {
            props: root.props
            visibilities: root.visibilities
        }
    }

    Component {
        id: recordingControls
        RowLayout {
            spacing: Appearance.spacing.normal

            StyledRect {
                radius: Appearance.rounding.full
                color: Recorder.paused ? Colours.palette.m3tertiary : Colours.palette.m3error

                implicitWidth: recText.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: recText.implicitHeight + Appearance.padding.smaller * 2

                StyledText {
                    id: recText
                    anchors.centerIn: parent
                    animate: true
                    text: Recorder.paused ? "PAUSED" : "REC"
                    color: Recorder.paused ? Colours.palette.m3onTertiary : Colours.palette.m3onError
                    font.family: Appearance.font.family.mono
                }

                Behavior on implicitWidth {
                    Anim {}
                }

                SequentialAnimation on opacity {
                    running: !Recorder.paused && root.actuallyRecording
                    alwaysRunToEnd: true
                    loops: Animation.Infinite
                    Anim {
                        from: 1
                        to: 0
                        duration: Appearance.anim.durations.large
                        easing.bezierCurve: Appearance.anim.curves.emphasizedAccel
                    }
                    Anim {
                        from: 0
                        to: 1
                        duration: Appearance.anim.durations.extraLarge
                        easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
                    }
                }
            }

            StyledText {
                text: {
                    const elapsed = Recorder.elapsed;
                    const hours = Math.floor(elapsed / 3600);
                    const mins = Math.floor((elapsed % 3600) / 60);
                    const secs = Math.floor(elapsed % 60).toString().padStart(2, "0");
                    let time;
                    if (hours > 0)
                        time = `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;
                    else
                        time = `${mins}:${secs}`;
                    return qsTr("Recording for %1").arg(time);
                }
                font.pointSize: Appearance.font.size.normal
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                label.animate: true
                icon: Recorder.paused ? "play_arrow" : "pause"
                toggle: true
                checked: Recorder.paused
                type: IconButton.Tonal
                font.pointSize: Appearance.font.size.large
                onClicked: {
                    Recorder.togglePause();
                }
            }

            IconButton {
                icon: "stop"
                inactiveColour: Colours.palette.m3error
                inactiveOnColour: Colours.palette.m3onError
                font.pointSize: Appearance.font.size.large
                onClicked: stopRecording()
            }
        }
    }

    function startRecording() {
        // Clear any previous errors
        root.lastError = "";

        const videoMode = Config.utilities.recording.videoMode || "fullscreen";
        const audioMode = root.currentAudioMode;

        root.currentVideoMode = videoMode;

        console.log("Starting recording - Video:", videoMode, "Audio:", audioMode);

        // Call Recorder service
        const success = Recorder.start(videoMode, audioMode);

        if (!success) {
            root.lastError = "Failed to start recording";
        }
    }

    function stopRecording() {
        root.lastError = "";
        Recorder.stop();
    }

    // Clear error after timeout
    Timer {
        id: errorTimeout
        interval: 10000
        repeat: false
        running: root.lastError !== ""
        onTriggered: {
            root.lastError = "";
        }
    }

    Connections {
        target: Recorder

        function onRunningChanged() {
            // Sync actuallyRecording with Recorder.running
            root.actuallyRecording = Recorder.running;

            if (!Recorder.running) {
                console.log("Recording stopped");
            }
        }

        function onErrorOccurred(errorMsg) {
            console.error("Recorder error:", errorMsg);
            root.lastError = errorMsg;
            errorTimeout.restart();
        }

        function onRecordingStarted() {
            console.log("Recording started successfully");
            root.lastError = "";
        }

        function onRecordingStopped() {
            console.log("Recording stopped successfully");
        }
    }

    Component.onCompleted: {
        // Sync initial state
        root.actuallyRecording = Recorder.running;
        root.currentVideoMode = Config.utilities.recording.videoMode || "fullscreen";
    }
}
