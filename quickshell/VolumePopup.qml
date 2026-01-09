import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland

PopupWindow {
    id: popup

    visible: false
    implicitWidth: 200
    implicitHeight: 100
    anchor.window: panelWindow
    color: "transparent"
    property bool hasEntered: false
        
    HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hoverHandler.hovered) {
                    parent.hasEntered = true
                } else if (parent.hasEntered) {
		    na.start()
                    parent.hasEntered = false
                }
            }
    }

    Item {
      id: container
      anchors.fill: parent

    // background
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

    Slider {
        id: volumeSlider

        snapMode: Slider.SnapAlways
        from: 0
        to: 100
        stepSize: 5
        z: 1
        implicitWidth: parent.width * 0.8
        value: volumeLevel
        onValueChanged: {
            volumeLevel = value;
            changeVolumeProcess.running = true;
        }

        anchors {
            leftMargin: 15
            rightMargin: 15
            centerIn: parent
        }

        Process {
            id: changeVolumeProcess

            command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", volumeLevel + "%"]
            running: false
        }

        background: Rectangle {
            x: volumeSlider.leftPadding
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 10
            width: volumeSlider.availableWidth
            height: implicitHeight
            radius: 20
            color: root.colPurple

            Rectangle {
                width: volumeSlider.visualPosition * parent.width
                height: parent.height
                color: root.colCyan
                radius: parent.radius
            }

        }

        handle: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
            implicitWidth: 15
            implicitHeight: 15
            radius: implicitWidth / 2
            color: root.colYellow
        }

    }

    Text {
        id: volumePopupText

        text: volumeLevel + "%"
        color: "#FFFFFF"
        font.pixelSize: 18
        font.family: root.fontFamily
        font.bold: true

        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 5
            horizontalCenter: parent.horizontalCenter
        }

    }
  }

    mask: Region {
        item: background
    }

    NumberAnimation {
      id: na
      duration: 1000;
      target: container
      properties: "opacity"
      from: 1.0
      to: 0.0
      onFinished: {
	popup.visible = false
	container.opacity = 1
      }
    }
}
