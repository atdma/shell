pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property alias running: props.running
    readonly property alias paused: props.paused
    readonly property alias elapsed: props.elapsed

    signal errorOccurred(string errorMsg)
    signal recordingStarted()
    signal recordingStopped()

    function start(videoMode: string, audioMode: string): bool {
        if (props.running) {
            console.warn("Recording already running");
            errorOccurred("Recording already in progress");
            return false;
        }

        // Build command array
        const args = ["caelestia", "record", "--mode", videoMode];

        if (audioMode && audioMode !== "none") {
            args.push("--audio", audioMode);
        }

        console.log("Executing:", args.join(" "));

        try {
            Quickshell.execDetached(args);
            props.running = true;
            props.paused = false;
            props.elapsed = 0;
            verifyTimer.restart();
            recordingStarted();
            return true;
        } catch (error) {
            console.error("Failed to start recording:", error);
            errorOccurred("Failed to execute recording command: " + error);
            props.running = false;
            return false;
        }
    }

    function stop(): void {
        if (!props.running) {
            console.warn("No recording to stop");
            return;
        }

        console.log("Stopping recording");

        try {
            Quickshell.execDetached(["caelestia", "record", "--stop"]);
            // Don't immediately set running to false - wait for process to confirm
            stopVerifyTimer.restart();
        } catch (error) {
            console.error("Failed to stop recording:", error);
            errorOccurred("Failed to stop recording: " + error);
            // Force state reset on error
            props.running = false;
            props.paused = false;
            props.elapsed = 0;
            recordingStopped();
        }
    }

    function togglePause(): void {
        if (!props.running) {
            console.warn("No recording to pause");
            return;
        }

        console.log("Toggling pause");

        try {
            Quickshell.execDetached(["caelestia", "record", "--pause"]);
            props.paused = !props.paused;
        } catch (error) {
            console.error("Failed to toggle pause:", error);
            errorOccurred("Failed to pause/resume recording: " + error);
        }
    }

    function verifyRunning(): bool {
        statusProc.running = true;
        return props.running;
    }

    PersistentProperties {
        id: props

        property bool running: false
        property bool paused: false
        property real elapsed: 0

        reloadableId: "recorder"
    }

    // Main process checker - runs periodically when recording
    Process {
        id: checkProc

        running: false
        command: ["pidof", "gpu-screen-recorder"]

        onExited: code => {
            const wasRunning = props.running;
            const isRunning = code === 0;

            // Detect unexpected stop
            if (wasRunning && !isRunning) {
                console.warn("Recording process stopped unexpectedly");
                props.running = false;
                props.paused = false;
                props.elapsed = 0;
                recordingStopped();
            }

            // Schedule next check if still recording
            if (props.running) {
                statusCheckTimer.restart();
            }
        }
    }

    // Verification timer after start
    Timer {
        id: verifyTimer
        interval: 1500
        repeat: false
        onTriggered: {
            console.log("Verifying recording started");
            statusProc.running = true;
        }
    }

    // Verification timer after stop
    Timer {
        id: stopVerifyTimer
        interval: 500
        repeat: false
        onTriggered: {
            console.log("Verifying recording stopped");
            stopStatusProc.running = true;
        }
    }

    // Status check process for start verification
    Process {
        id: statusProc

        running: false
        command: ["pidof", "gpu-screen-recorder"]

        onExited: code => {
            const isRunning = code === 0;

            if (!isRunning && props.running) {
                console.error("Recording process failed to start");
                errorOccurred("Recording process failed to start");
                props.running = false;
                props.paused = false;
                props.elapsed = 0;
            } else if (isRunning && props.running) {
                console.log("Recording verified running");
                statusCheckTimer.restart();
            }
        }
    }

    // Status check process for stop verification
    Process {
        id: stopStatusProc

        running: false
        command: ["pidof", "gpu-screen-recorder"]

        onExited: code => {
            const isRunning = code === 0;

            if (!isRunning) {
                console.log("Recording stopped successfully");
                props.running = false;
                props.paused = false;
                props.elapsed = 0;
                recordingStopped();
            } else {
                // Process still running, try again
                console.warn("Process still running, checking again");
                stopVerifyTimer.restart();
            }
        }
    }

    // Elapsed time tracker
    Timer {
        id: elapsedTimer
        interval: 1000
        repeat: true
        running: props.running && !props.paused

        onTriggered: {
            props.elapsed++;
        }
    }

    // Periodic status check while recording
    Timer {
        id: statusCheckTimer
        interval: 3000
        repeat: false

        onTriggered: {
            if (props.running) {
                checkProc.running = true;
            }
        }
    }

    // Initialize on component completion
    Component.onCompleted: {
        console.log("Recorder service initialized");
        // Check initial state
        initialStatusProc.running = true;
    }

    // Initial status check
    Process {
        id: initialStatusProc

        running: false
        command: ["pidof", "gpu-screen-recorder"]

        onExited: code => {
            if (code === 0) {
                console.log("Found existing recording process");
                props.running = true;
                statusCheckTimer.restart();
            } else {
                console.log("No existing recording process");
                props.running = false;
                props.paused = false;
                props.elapsed = 0;
            }
        }
    }

    // Cleanup on destruction
    Component.onDestruction: {
        if (props.running) {
            console.log("Service destroyed while recording - stopping recording");
            try {
                Quickshell.execDetached(["caelestia", "record", "--stop"]);
            } catch (error) {
                console.error("Failed to stop recording on cleanup:", error);
            }
        }
    }
}
