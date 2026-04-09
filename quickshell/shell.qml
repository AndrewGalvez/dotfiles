import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Bluetooth
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
    property color colBg: "transparent"
    property color colFg: "#d3c6aa"
    property color colMuted: "#475258"
    property color colCyan: "#83c092"
    property color colPurple: "#d699b6"
    property color colRed: "#e67e80"
    property color colYellow: "#dbbc7f"
    property color colBlue: "#7fbbb3"
    property string fontFamily: "Code Nerd"
    property int fontSize: 14
    property int volumeLevel: 0

    Process {
        id: volProc
        command: ["pactl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
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

	    exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

	    mask: Region {}

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 65
            color: root.colBg

            Rectangle {
                color: root.colBg
                anchors.fill: parent

                RowLayout {
                    spacing: 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Item { Layout.fillWidth: true }

//                  Rectangle {
//                      color: Qt.rgba(0.5, 0.5, 0.5, 0.5)
//                      radius: 4
//                      Layout.rightMargin: 8
//                      Layout.alignment: Qt.AlignVCenter
//                      width: mprisItem.width + 12
//                      height: 22
//                      Item {
//                          id: mprisItem
//                          anchors.centerIn: parent
//                          height: childrenRect.height
//                          width: childrenRect.width
//                          MprisWidget {}
//                      }
//                  }

//                  Rectangle {
//                      color: Qt.rgba(0.5, 0.5, 0.5, 0.5)
//                      radius: 4
//                      Layout.rightMargin: 8
//                      Layout.alignment: Qt.AlignVCenter
//                      implicitWidth: volText.width + 12
//                      implicitHeight: 22
//                      Text {
//                          id: volText
//                          anchors.centerIn: parent
//                          text: "Vol: " + volumeLevel + "%"
//                          color: root.colPurple
//                          font.pixelSize: root.fontSize
//                          font.family: root.fontFamily
//                          font.bold: true
//                          MouseArea {
//                              anchors.fill: parent
//                              onClicked: {
//                                  var pos = volText.mapToItem(panelWindow.contentItem, 0, 0)
//                                  popup.anchor.rect.x = pos.x - popup.width / 2 + width / 2
//                                  popup.anchor.rect.y = pos.y + panelWindow.implicitHeight
//                                  popup.visible = !popup.visible
//                                  popup.container.opacity = 0
//                                  na2.start()
//                              }
//                          }
//                          VolumePopup { id: popup }
//                      }
//                  }

                    Rectangle {
                        color: Qt.rgba(0.5, 0.5, 0.5, 0.5)
                        radius: 4
                        Layout.rightMargin: 8
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: clockText.width + 12
                        implicitHeight: 22
                        Text {
                            id: clockText
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - hh:mm:ss AP")
                            color: root.colCyan
                            font.pixelSize: root.fontSize
                            font.family: root.fontFamily
                            font.bold: true
                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - hh:mm:ss AP")
                            }
                        }
                    }

		    Item { width: 10 }

		    Rectangle {
		      visible: UPower.displayDevice.isLaptopBattery
		      color: Qt.rgba(0.5,0.5,0.5,0.5)
		      radius: 4
		      Layout.rightMargin: 8
		      Layout.alignment: Qt.AlignVCenter
		      implicitWidth: batteryText.width + 12
		      implicitHeight: 22
		      Text {
			id: batteryText
			anchors.centerIn: parent

			function formatSeconds(seconds) {
			  let t = seconds
			  let nseconds = t % 60;
			  t = Math.floor(t / 60);
			  let mins = t % 60;
			  t = Math.floor(t / 60);
			  let hours = t % 60;
			  return hours + (hours > 0 ? ":" : "") + mins
			}

			text: Math.round(UPower.displayDevice.percentage * 100) + "% (" + (UPower.displayDevice.changeRate < 0 ? formatSeconds(UPower.displayDevice.timeToFull) : formatSeconds(UPower.displayDevice.timeToEmpty)) + ")"
			color: root.colCyan
			font.pixelSize: root.fontSize
			font.family: root.fontFamily
			font.bold: true
		      }
		    }

		    Item { width: 10 }
Rectangle {
    color: Qt.rgba(0.5,0.5,0.5,0.5)
    radius: 4
    Layout.rightMargin: 8
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: bluetoothText.width + 32
    implicitHeight: 22

    Row {
      anchors.fill: parent
      spacing: 5

    Image {
      source: "https://img.icons8.com/?size=100&id=19333&format=png&color=000000"
      cache: true
      width: 20
      height: 20
    }

    Text  {
        id: bluetoothText
        color: root.colCyan
        font.pixelSize: root.fontSize
        font.family: root.fontFamily
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
        text: Bluetooth.devices.values.filter(d => d.connected).length > 0 ? Bluetooth.devices.values.filter(d =>d.connected)[0].name + (Bluetooth.devices.values.filter(d=>d.connected)[0].batteryAvailable ? (" (" + Bluetooth.devices.values.filter(d=>d.connected)[0].battery * 100 + "%)") : "") : "no device"
	
    }
  }
}
                    Item { width: 18 }
		    Rectangle {
		      property int brightness: -1;
    color: Qt.rgba(0.5,0.5,0.5,0.5)
    radius: 4
    Layout.rightMargin: 8
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: brightnessText.width + 12
    implicitHeight: 22
    id: brightnessRect

    Text {
      Process { 
	running: true
	command: [ "brightnessctl", "g" ]
	stdout: StdioCollector {
	  onStreamFinished: brightnessRect.brightness = this.text / 1200
	}
	id: brightnessGetProcess
      }

      Timer {
	repeat: true
	interval: 2000
	running: true
	onTriggered: brightnessGetProcess.running = true
      }

    id: brightnessText
        color: root.colCyan
        font.pixelSize: root.fontSize
        font.family: root.fontFamily
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
	text: parent.brightness + "%"
	anchors.centerIn: parent
     
    }

		    }
                    Item { width: 18 }
                }
            }
        }
    }
}
