
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland

Popup {
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
