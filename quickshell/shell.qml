import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

ShellRoot {
    id: root

    // Theme colors
    property color colBg: "#272e33"
    property color colFg: "#d3c6aa"
    property color colMuted: "#475258"
    property color colCyan: "#83c092"
    property color colPurple: "#d699b6"
    property color colRed: "#e67e80"
    property color colYellow: "#dbbc7f"
    property color colBlue: "#7fbbb3"
    // Font
    property string fontFamily: "Fira Code"
    property int fontSize: 14

    // System info properties
    property int volumeLevel: 0


    // Volume level (wpctl for PipeWire)
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    volumeLevel = Math.round(parseFloat(match[1]) * 100)
                }
            }
        }
        Component.onCompleted: running = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
	  id: panelWindow
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30
            color: root.colBg

            margins {
                top: 0
                bottom: 0
                left: 0
                right: 0
            }

            Rectangle {
                color: root.colBg
		anchors.fill: parent

RowLayout {
    spacing: 0
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right

    Item { width: 8 }

    Item { width: 8 }

    Repeater {
        model: 10

        Rectangle {
            width: 20
            Layout.fillWidth: false
            Layout.preferredHeight: parent.height
            color: "transparent"

            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            property bool hasWindows: workspace !== null

            Text {
	      text: index == 9 ? 0 : index + 1
                color: parent.isActive ? root.colPurple : (parent.hasWindows ? root.colCyan : root.colMuted)
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
                anchors.centerIn: parent
            }


            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.fillWidth: false
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 8
        Layout.rightMargin: 8
        color: root.colMuted
    }

    Item {
        Layout.fillWidth: true
    }

    Item {
        Layout.preferredWidth: 200
        Layout.fillWidth: false
        height: childrenRect.height

        MprisWidget {
        }
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.fillWidth: false
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 8
        Layout.rightMargin: 8
        color: root.colMuted
    }

    Text {
        id: volText
        Layout.fillWidth: false
        text: "Vol: " + volumeLevel + "%"
        color: root.colPurple
        font.pixelSize: root.fontSize
        font.family: root.fontFamily
        font.bold: true
        Layout.rightMargin: 8

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var pos = volText.mapToItem(panelWindow.contentItem, 0, 0)
                popup.anchor.rect.x = pos.x - popup.width / 2 + width / 2
                popup.anchor.rect.y = pos.y + panelWindow.implicitHeight
                popup.visible = !popup.visible
                popup.container.opacity = 0;
                na2.start();
            }
        }

        VolumePopup {
            id: popup
        }
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 0
        Layout.rightMargin: 8
        color: root.colMuted
        Layout.fillWidth: false
    }

    Text {
        id: clockText
        Layout.fillWidth: false
        text: Qt.formatDateTime(new Date(), "ddd, MMM dd - hh:mm:ss AP")
        color: root.colCyan
        font.pixelSize: root.fontSize
        font.family: root.fontFamily
        font.bold: true
        Layout.rightMargin: 8

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - hh:mm:ss AP")
        }
    }

    Item { width: 8 }
}
            }
        }
    }
}
