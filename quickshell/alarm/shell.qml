import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
    id: root

    property bool shown: false

    IpcHandler {
        target: "alarm"
        function toggle(): void { root.shown = !root.shown }
        function show(): void   { root.shown = true }
        function hide(): void   { root.shown = false }
    }

    PanelWindow {
        id: win
        visible: root.shown
        focusable: true
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay

        implicitWidth: 500
        implicitHeight: 58
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                input.text = ""
                input.color = "#e8e8e8"
                Qt.callLater(() => input.forceActiveFocus())
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#0d0d0d"
            border.color: "#2a2a2a"
            border.width: 1
            radius: 6

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16
                spacing: 10

                Text {
                    text: "⏱"
                    color: "#555"
                    font.pixelSize: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: input
                    width: 420
                    color: "#e8e8e8"
                    selectionColor: "#2a2a2a"
                    font.pixelSize: 20
                    font.family: "monospace"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        visible: parent.text.length === 0
                        text: "5m  ·  1h30m  ·  14:30  ·  2:30pm"
                        color: "#333"
                        font: parent.font
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Keys.onReturnPressed: {
                        var result = root.parseInput(text.trim().toLowerCase())
                        if (result.seconds > 0) {
                            alarmProc.startAlarm(result.seconds, result.label)
                            root.notify("low", "⏱ Set", result.label + " started")
                            root.shown = false
                        } else {
                            root.notify("normal", "✗ Invalid", "Couldn't parse \"" + text + "\"")
                            color = "#ff4444"
                        }
                    }

                    Keys.onEscapePressed: {
                        root.shown = false
                        root.notify("low", "✗ Dismissed", "Alarm input cancelled")
                    }
                    onTextChanged: color = "#e8e8e8"
                }
            }
        }
    }

    function notify(urgency, summary, body) {
        var proc = notifComponent.createObject(null)
        proc.urgency = urgency
        proc.summary = summary
        proc.body = body
        proc.running = true
    }

    function parseInput(text) {
        var m = text.match(/^(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?$/)
        if (m && (m[1] || m[2] || m[3])) {
            var secs = (parseInt(m[1] || 0) * 3600)
                     + (parseInt(m[2] || 0) * 60)
                     + parseInt(m[3] || 0)
            if (secs > 0) {
                var lbl = (m[1] ? m[1]+"h" : "") + (m[2] ? m[2]+"m" : "") + (m[3] ? m[3]+"s" : "")
                return { seconds: secs, label: "Timer: " + lbl }
            }
        }
        m = text.match(/^(\d{1,2}):(\d{2})(?::(\d{2}))?(?:\s*(am|pm))?$/)
        if (m) {
            var h = parseInt(m[1]), min = parseInt(m[2]), sec = parseInt(m[3] || 0)
            if (m[4] === "pm" && h !== 12) h += 12
            if (m[4] === "am" && h === 12) h = 0
            var now = new Date()
            var target = new Date(now)
            target.setHours(h, min, sec, 0)
            if (target <= now) target.setDate(target.getDate() + 1)
            var diff = Math.round((target - now) / 1000)
            var pad = n => String(n).padStart(2, "0")
            return { seconds: diff, label: "Alarm: " + pad(h)+":"+pad(min)+":"+pad(sec) }
        }
        return { seconds: 0, label: "" }
    }

    QtObject {
        id: alarmProc
        function startAlarm(seconds, label) {
            var proc = procComponent.createObject(null)
            proc.seconds = seconds
            proc.label = label
            proc.running = true
        }
    }

    Component {
        id: notifComponent
        Process {
            property string urgency: "low"
            property string summary: ""
            property string body: ""
            command: ["notify-send", "-u", urgency, summary, body]
            onRunningChanged: if (!running) destroy()
        }
    }

    Component {
        id: procComponent
        Process {
            property int seconds: 0
            property string label: ""
            command: ["/bin/bash", Qt.resolvedUrl("alarm.sh").toString().replace("file://", ""), String(seconds), label]
            onRunningChanged: if (!running) destroy()
        }
    }
}
