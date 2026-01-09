import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland

Text {
    property var mprisPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property real trackProgress: 0
    property real trackLen: 0
    property string txt: {
       if (!mprisPlayer)
            return "No player"
        
        const meta = mprisPlayer.metadata
        if (!meta)
            return "No metadata"
        
        const title = meta["xesam:title"] || meta.trackTitle || "Unknown"
        const artist = meta["xesam:artist"]?.[0] || meta.trackArtist || "Unknown"

        return `${title} - ${artist}`;
    }

    text: txt
    color: root.colPurple
    font.pixelSize: root.fontSize
    font.family: root.fontFamily
    font.bold: true
    Layout.rightMargin: 8

Timer {
    interval: 500
    running: popup.visible && mprisPlayer
    repeat: true
    onTriggered: {
        if (mprisPlayer) {
            console.log("Position:", mprisPlayer.position, "Length:", mprisPlayer.length)
            trackProgress = mprisPlayer.position
            trackLen = mprisPlayer.length
        }
    }
}
    MouseArea {
        anchors.fill: parent
        onClicked: {
            var pos = parent.mapToItem(panelWindow.contentItem, 0, 0);
            popup.anchor.rect.x = pos.x - popup.width / 2 + width / 2;
            popup.anchor.rect.y = pos.y + panelWindow.implicitHeight;
            popup.visible = !popup.visible;
        }
    }

    PopupWindow {
        id: popup
        property bool hasEntered: false
        visible: false
        implicitWidth: 500
        implicitHeight: 300
        anchor.window: panelWindow
        color: "transparent"

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hoverHandler.hovered) {
                    parent.hasEntered = true;
                } else if (parent.hasEntered) {
                    na.start();
                    parent.hasEntered = false;
                }
            }
        }

        Item {
            id: container
            anchors.fill: parent

            Rectangle {
                id: background
                anchors.fill: parent
                radius: 20
                color: root.colBg
                border {
                    color: "#FFFFFF"
                    width: 2
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: txt
                    font.pixelSize: 18
                    font.bold: true
                    font.family: root.fontFamily
                    color: root.colPurple
                    Layout.alignment: Qt.AlignCenter
                    Layout.maximumWidth: parent.width * 0.9
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.maximumWidth: parent.width * 0.9
                    spacing: 5

                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: trackLen > 0 ? trackLen : 1
                        value: pressed ? value : trackProgress
			enabled: mprisPlayer !== null
			onPressedChanged: {
			  if (!pressed && mprisPlayer) {
			    mprisPlayer.position = value
			  }
			}
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: {
                                const mins = Math.floor(trackProgress / 60)
                                const secs = Math.floor(trackProgress % 60)
                                return `${mins}:${secs.toString().padStart(2, '0')}`
                            }
                            color: root.colPurple
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: {
                                const mins = Math.floor(trackLen / 60)
                                const secs = Math.floor(trackLen % 60)
                                return `${mins}:${secs.toString().padStart(2, '0')}`
                            }
                            color: root.colPurple
                            font.pixelSize: 12
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignCenter
                    spacing: 20

                    Button {
                        icon.source: "https://img.icons8.com/?size=100&id=26144&format=png&color=000000"
                        icon.name: "previous"
                        icon.width: 60
                        icon.height: 60
                        icon.cache: true
                        icon.color: this.hovered ? root.colBlue : root.colYellow
                        flat: true
                        onClicked: if (mprisPlayer) mprisPlayer.previous()
			background: Rectangle { color: "transparent" }
                    }

                    Button {
                        icon.source: "https://img.icons8.com/?size=100&id=c0noYZUL0kat&format=png&color=000000"
                        icon.name: "playpause"
                        icon.width: 60
                        icon.height: 60
                        icon.cache: true
			icon.color: this.hovered ? root.colBlue : root.colYellow
			flat: true
                        onClicked: if (mprisPlayer) mprisPlayer.togglePlaying()
			background: Rectangle { color: "transparent" }
                    }

                    Button {
                        icon.source: "https://img.icons8.com/?size=100&id=26138&format=png&color=000000"
                        icon.name: "next"
                        icon.width: 60
                        icon.height: 60
                        icon.cache: true
                        icon.color: this.hovered ? root.colBlue : root.colYellow
                        flat: true
                        onClicked: if (mprisPlayer) mprisPlayer.next()
			background: Rectangle { color: "transparent" }

                    }
                }
            }
        }

        NumberAnimation {
            id: na
            duration: 500
            target: container
            properties: "opacity"
            from: 1
            to: 0
            onFinished: {
                popup.visible = false;
                container.opacity = 1;
            }
        }

        mask: Region {
            item: background
        }
    }
}
