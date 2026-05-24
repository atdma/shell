pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property var props
    required property DrawerVisibilities visibilities

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + layout.anchors.margins * 2

    radius: Tokens.rounding.normal
    color: Colours.tPalette.m3surfaceContainer

    property bool actuallyRecording: Recorder.running
    readonly property bool recordingBusy: Recorder.running || Recorder.starting
    property string lastError: ""
    property string currentVideoMode: Recorder.videoMode || Config.utilities.recording.videoMode || "fullscreen"

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
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.normal

        RowLayout {
            spacing: Tokens.spacing.normal
            z: 1

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: {
                    const h = icon.implicitHeight + Tokens.padding.smaller * 2;
                    return h - (h % 2);
                }

                radius: Appearance.rounding.full
                color: root.recordingBusy ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    id: icon

                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: -0.5
                    anchors.verticalCenterOffset: 1.5
                    text: "screen_record"
                    color: root.recordingBusy ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Screen Recorder")
                    font.pointSize: Tokens.font.size.normal
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        if (root.lastError !== "") return qsTr("Error: %1").arg(root.lastError);
                        if (Recorder.starting) return root.startingText(Recorder.videoMode || root.currentVideoMode);
                        if (Recorder.paused) return qsTr("Recording paused");
                        if (root.actuallyRecording) {
                            const videoText = root.videoModeLabel(Recorder.videoMode || root.currentVideoMode);
                            const audioText = root.audioModeLabel(Recorder.audioMode || root.currentAudioMode);
                            return qsTr("Recording %1 with %2").arg(videoText).arg(audioText);
                        }
                        return qsTr("Recording off");
                    }
                    color: root.lastError !== "" ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }
            }

            SplitButton {
                disabled: root.recordingBusy
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
                        onClicked: startRecording(mode)
                    },
                    MenuItem {
                        property string mode: "region"
                        icon: "screenshot_region"
                        text: qsTr("Record region")
                        activeText: qsTr("Region")
                        onClicked: startRecording(mode)
                    },
                    MenuItem {
                        property string mode: "window"
                        icon: "web_asset"
                        text: qsTr("Record window")
                        activeText: qsTr("Window")
                        onClicked: startRecording(mode)
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
            visible: !root.recordingBusy
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
                    icon: root.props.recordingAudioExpanded ? "unfold_less" : "unfold_more"
                    type: IconButton.Text
                    label.animate: true
                    onClicked: {
                        root.props.recordingAudioExpanded = !root.props.recordingAudioExpanded;
                    }
                }
            }

            Item {
                id: audioSourcesContainer

                Layout.fillWidth: true
                Layout.preferredHeight: root.props.recordingAudioExpanded ? audioSourcesLayout.implicitHeight : 0
                clip: true
                enabled: root.props.recordingAudioExpanded
                opacity: root.props.recordingAudioExpanded ? 1 : 0
                visible: root.props.recordingAudioExpanded || height > 0

                ColumnLayout {
                    id: audioSourcesLayout

                    width: parent.width
                    y: root.props.recordingAudioExpanded ? 0 : -Appearance.spacing.small
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

                    Behavior on y {
                        Anim { duration: Appearance.anim.durations.small }
                    }
                }

                Behavior on Layout.preferredHeight {
                    Anim { type: Anim.DefaultSpatial }
                }

                Behavior on opacity {
                    Anim { duration: Appearance.anim.durations.small }
                }
            }
        }

        Loader {
            id: listOrControls

            property bool running: root.recordingBusy

            asynchronous: true
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
                            duration: Tokens.anim.durations.small
                            easing: Tokens.anim.standardAccel
                        }
                        Anim {
                            target: listOrControls
                            property: "opacity"
                            to: 0
                            duration: Tokens.anim.durations.small
                            easing: Tokens.anim.standardAccel
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
                            duration: Tokens.anim.durations.small
                            easing: Tokens.anim.standardDecel
                        }
                        Anim {
                            target: listOrControls
                            property: "opacity"
                            to: 1
                            duration: Tokens.anim.durations.small
                            easing: Tokens.anim.standardDecel
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
            spacing: Tokens.spacing.normal

            StyledRect {
                radius: Appearance.rounding.full
                color: Recorder.starting ? Colours.palette.m3secondary : Recorder.paused ? Colours.palette.m3tertiary : Colours.palette.m3error

                implicitWidth: recText.implicitWidth + Tokens.padding.normal * 2
                implicitHeight: recText.implicitHeight + Tokens.padding.smaller * 2

                StyledText {
                    id: recText
                    anchors.centerIn: parent
                    animate: true
                    text: Recorder.starting ? "WAIT" : Recorder.paused ? "PAUSED" : "REC"
                    color: Recorder.starting ? Colours.palette.m3onSecondary : Recorder.paused ? Colours.palette.m3onTertiary : Colours.palette.m3onError
                    font.family: Appearance.font.family.mono
                }

                Behavior on implicitWidth {
                    Anim {}
                }

                SequentialAnimation on opacity {
                    running: !Recorder.starting && !Recorder.paused && root.actuallyRecording
                    alwaysRunToEnd: true
                    loops: Animation.Infinite
                    Anim {
                        from: 1
                        to: 0
                        duration: Tokens.anim.durations.large
                        easing: Tokens.anim.emphasizedAccel
                    }
                    Anim {
                        from: 0
                        to: 1
                        duration: Tokens.anim.durations.extraLarge
                        easing: Tokens.anim.emphasizedDecel
                    }
                }
            }

            StyledText {
                text: {
                    if (Recorder.starting)
                        return root.startingText(Recorder.videoMode || root.currentVideoMode);

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
                font.pointSize: Tokens.font.size.normal
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                disabled: Recorder.starting
                label.animate: true
                icon: Recorder.paused ? "play_arrow" : "pause"
                toggle: true
                checked: Recorder.paused
                type: IconButton.Tonal
                font.pointSize: Tokens.font.size.large
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

    function videoModeLabel(mode) {
        switch (mode) {
        case "region": return qsTr("Region");
        case "window": return qsTr("Window");
        default: return qsTr("Fullscreen");
        }
    }

    function audioModeLabel(mode) {
        switch (mode) {
        case "combined": return qsTr("system audio + microphone");
        case "system": return qsTr("system audio");
        case "mic": return qsTr("microphone");
        default: return qsTr("no audio");
        }
    }

    function startingText(mode) {
        switch (mode) {
        case "region": return qsTr("Select a recording region");
        case "window": return qsTr("Select a window to record");
        default: return qsTr("Starting fullscreen recording");
        }
    }

    function startRecording(videoMode) {
        // Clear any previous errors
        root.lastError = "";

        const selectedVideoMode = videoMode || Config.utilities.recording.videoMode || "fullscreen";
        const audioMode = root.currentAudioMode;

        Config.utilities.recording.videoMode = selectedVideoMode;
        root.currentVideoMode = selectedVideoMode;

        console.log("Starting recording - Video:", selectedVideoMode, "Audio:", audioMode);

        // Call Recorder service
        const success = Recorder.start(selectedVideoMode, audioMode);

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
        root.currentVideoMode = Recorder.videoMode || Config.utilities.recording.videoMode || "fullscreen";
    }
}
