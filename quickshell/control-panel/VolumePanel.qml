import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Services.Mpris

ShellRoot {
    QtObject {
        id: state
        property int volume: 50
        property bool muted: false
        property bool shown: true
    }

    Process {
        id: refreshVolume
        running: true
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1"]
        stdout: SplitParser {
            onRead: data => state.volume = parseInt(data)
        }
    }

    Process {
        id: refreshMute
        running: true
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes\\|no'"]
        stdout: SplitParser {
            onRead: data => state.muted = data.trim() === "yes"
        }
    }

    Process {
        id: setVolume
        property string cmd: ""
        command: ["sh", "-c", cmd]
        onRunningChanged: if (!running && cmd !== "") { refreshVolume.running = true; refreshMute.running = true }
    }

    Process {
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink") || data.includes("server")) {
                    refreshVolume.running = true
                    refreshMute.running = true
                }
            }
        }
    }

    Process {
        id: pavucontrol
        command: ["pavucontrol"]
    }

    IpcHandler {
        target: "volume"
        function toggle(): void { state.shown = !state.shown }
    }

    PanelWindow {
        id: panel
        visible: state.shown
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: mainCol.implicitHeight + 20
        exclusionMode: ExclusionMode.Ignore
        focusable: true
        color: "transparent"

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Item {
            anchors.fill: parent

            ColumnLayout {
                id: mainCol
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                spacing: 6
                width: 340

                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 16
                    color: "#1a1a2e"
                    border.color: "#ffffff18"
                    border.width: 1

                    RowLayout {
                        anchors { fill: parent; margins: 18 }
                        spacing: 14

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 10
                            color: state.muted ? "#3d1a1a" : "#1a2e3d"

                            Text {
                                anchors.centerIn: parent
                                text: state.muted ? "󰝟" : state.volume > 100 ? "󰕾" : state.volume > 50 ? "󰖀" : state.volume > 0 ? "󰕿" : "󰕿"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                                color: "#e0e0ff"
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

                                handle: Rectangle {
                                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: state.muted ? "#555" : "#ffffff"
                                    border.color: state.muted ? "#444" : "#5b8dee"
                                    border.width: 2
                                }
                            }
                        }

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 10
                            color: "#1a2e3d"
                            Text {
                                anchors.centerIn: parent
                                text: "󰒓"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                                color: "#e0e0ff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: pavucontrol.running = true
                            }
                        }
                    }
                }

                Repeater {
                    model: Mpris.players

                    delegate: Rectangle {
                        required property MprisPlayer modelData
                        Layout.fillWidth: true
                        height: 70
                        radius: 16
                        color: "#1a1a2e"
                        border.color: "#ffffff18"
                        border.width: 1

                        ColumnLayout {
                            anchors { fill: parent; margins: 14 }
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "󰎆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: "#5b8dee"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.trackTitle || "Unknown Title"
                                        color: "#e0e0ff"
                                        font.pixelSize: 12
                                        font.bold: true
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.trackArtist || "Unknown Artist"
                                        color: "#a0a0c0"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8

                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 8
                                    color: modelData.canGoPrevious ? "#1a2e3d" : "#111122"
                                    opacity: modelData.canGoPrevious ? 1.0 : 0.4

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒮"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                        color: "#e0e0ff"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: modelData.canGoPrevious
                                        onClicked: modelData.previous()
                                    }
                                }

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 10
                                    color: "#5b8dee"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.isPlaying ? "󰏤" : "󰐊"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: "#ffffff"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: modelData.canTogglePlaying
                                        onClicked: modelData.togglePlaying()
                                    }
                                }

                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 8
                                    color: modelData.canGoNext ? "#1a2e3d" : "#111122"
                                    opacity: modelData.canGoNext ? 1.0 : 0.4

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒭"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                        color: "#e0e0ff"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: modelData.canGoNext
                                        onClicked: modelData.next()
                                    }
                                }
                            }
                        }
                    }
                }

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 56
                        radius: 16
                        color: "#1a1a2e"
                        border.color: "#ffffff18"
                        border.width: 1

                        RowLayout {
                            anchors { fill: parent; margins: 14 }
                            spacing: 12

                            Text {
                                text: "󰂱"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 20
                                color: "#5b8dee"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.name
                                    color: "#e0e0ff"
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.hasBattery ? "Battery: " + modelData.battery + "%" : "No battery info"
                                    color: {
                                        if (!modelData.hasBattery) return "#606080"
                                        if (modelData.battery <= 20) return "#e05555"
                                        if (modelData.battery <= 50) return "#e0a855"
                                        return "#55e08a"
                                    }
                                    font.pixelSize: 11
                                }
                            }

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 8
                                color: "#3d1a1a"

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰂲"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 16
                                    color: "#e05555"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: modelData.connected = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
