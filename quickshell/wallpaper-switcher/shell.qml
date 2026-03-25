import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Window
import Qt.labs.folderlistmodel
import QtQuick.Layouts
import QtQuick.Controls

Window {
  width: 1540
  height: 840
  visible: true
  title: qsTr("wallpaper-switcher")
  color: "#2d353b"

  FolderListModel {
    id: folderModel
    folder: "file:///home/turtle/Pictures/Wallpapers"
    nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
    onCountChanged: applyFilter()
  }

  ListModel {
    id: filteredModel
  }

  function applyFilter() {
    filteredModel.clear()
    for (var i = 0; i < folderModel.count; i++) {
      var name = folderModel.get(i, "fileName")
      var url = folderModel.get(i, "fileUrl")
      if (searchBar.text === "" || name.toLowerCase().indexOf(searchBar.text.toLowerCase()) !== -1)
        filteredModel.append({ fileName: name, fileUrl: url })
    }
  }

  Column {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    TextField {
      id: searchBar
      width: parent.width
      placeholderText: "Search wallpapers..."
      color: "#d3c6aa"
      font.family: "monospace"
      font.pixelSize: 13
      background: Rectangle {
        color: "#343f44"
        radius: 6
      }
      leftPadding: 10
      onTextChanged: applyFilter()
    }

    GridView {
      id: grid
      width: parent.width
      height: parent.height - searchBar.height - 8
      cellWidth: 1920 / 4 + 12
      cellHeight: 1080 / 4 + 48
      cacheBuffer: cellHeight * 2
      model: filteredModel

      delegate: Item {
        width: 1920 / 4
        height: 1080 / 4 + 36

        Rectangle {
          anchors.fill: parent
          color: mouseArea.containsMouse ? "#3d4f56" : "#343f44"
          radius: 6

          Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6

            Image {
              width: parent.width
              height: 1080 / 4 - 6
              source: model.fileUrl
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              sourceSize.width: 1920 / 4
              sourceSize.height: 1080 / 4
              cache: true

              Rectangle {
                anchors.fill: parent
                color: "#343f44"
                visible: parent.status !== Image.Ready
              }
            }

            Text {
              width: parent.width
              text: model.fileName
              horizontalAlignment: Text.AlignHCenter
              elide: Text.ElideMiddle
              color: "#d3c6aa"
              font.pixelSize: 12
              font.family: "monospace"
            }
          }
        }

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            hyprpaperProc.command = ["hyprctl", "hyprpaper", "wallpaper", "," + model.fileUrl.toString().replace("file://", "")]
            hyprpaperProc.running = true
          }
        }
      }

      footer: Item {
        width: grid.width
        height: 60
        Button {
          anchors.centerIn: parent
          text: "exit"
          onClicked: Qt.quit()
        }
      }
    }
  }

  Process {
    id: hyprpaperProc
  }
}
