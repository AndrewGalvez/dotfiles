import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: false

    IpcHandler {
        target: "controlpanel"
        function toggle(): void { root.shown = !root.shown }
        function show(): void   { root.shown = true }
        function hide(): void   { root.shown = false }
    }


    QtObject {
        id: state
        property int volume: 50
        property bool muted: false
    }

    Process {
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => state.volume = parseInt(data)
        }
    }

    Process {
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes\\|no'"]
        running: true
        stdout: SplitParser {
            onRead: data => state.muted = data.trim() === "yes"
        }
    }

    Process {
        id: setVolume
        property string cmd: ""
        command: ["sh", "-c", cmd]
    }

    PanelWindow {
        id: panel
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 100
        exclusionMode: ExclusionMode.Ignore
        focusable: true
        color: "transparent"
	visible: root.shown

	WlrLayershell.namespace: "quickshell:controlpanel"

        mask: Region {
            item: panel_rect
        }

        Item {
            anchors.fill: parent

            Rectangle {
                id: panel_rect
                width: 300
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                radius: 16
                color: "#1a1a2e"
                border.color: "#ffffff18"
                border.width: 1

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 18
                    }
                    spacing: 14

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 10
                        color: state.muted ? "#3d1a1a" : "#1a2e3d"

                        Text {
                            anchors.centerIn: parent
                            text: state.muted ? "🔇" : state.volume > 50 ? "🔊" : state.volume > 0 ? "🔉" : "🔈"
                            font.pixelSize: 18
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                state.muted = !state.muted
                                setVolume.cmd = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
                                setVolume.running = true
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Text {
                                text: "Volume"
                                color: "#a0a0c0"
                                font.pixelSize: 11
                                font.letterSpacing: 1.5
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: state.muted ? "Muted" : state.volume + "%"
                                color: state.muted ? "#e05555" : "#e0e0ff"
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }

                        Slider {
                            id: slider
                            Layout.fillWidth: true
                            from: 0
                            to: 150
                            value: state.volume
                            enabled: !state.muted

                            onMoved: {
                                state.volume = Math.round(value)
                                setVolume.cmd = "pactl set-sink-volume @DEFAULT_SINK@ " + state.volume + "%"
                                setVolume.running = true
                            }

                            background: Rectangle {
                                x: slider.leftPadding
                                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                                width: slider.availableWidth
                                height: 5
                                radius: 3
                                color: "#2a2a4a"

                                Rectangle {
                                    width: slider.visualPosition * parent.width
                                    height: parent.height
                                    radius: 3
                                    color: state.muted ? "#555" : state.volume > 100 ? "#e05555" : "#5b8dee"
                                }
                            }

                        }
                    }
                }
            }
        }
    }
}
