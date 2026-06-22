import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property string appId: ""
    property string appName: ""
    property string appIcon: ""
    property string appPath: ""
    property bool isHovered: false

    width: 96
    height: 80

    Rectangle {
        id: background
        anchors.centerIn: parent
        width: 88
        height: 72
        radius: 8
        color: parent.isHovered ? "#E5E5E5" : "transparent"
        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        Column {
            anchors.centerIn: parent
            spacing: 6

            // App Icon
            Image {
                id: iconImage
                width: 36
                height: 36
                source: appIcon ? "image://icon/" + appIcon : "qrc:/icons/default-app.svg"
                sourceSize: Qt.size(36, 36)
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    color: "#0078D4"
                    radius: 8
                    visible: iconImage.status === Image.Error || iconImage.source === ""

                    Text {
                        anchors.centerIn: parent
                        text: appName.length > 0 ? appName[0].toUpperCase() : "?"
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
            }

            // App Name
            Text {
                text: appName
                color: "#1F1F1F"
                font.pixelSize: 12
                font.family: "Segoe UI"
                elide: Text.ElideRight
                maximumLineCount: 1
                anchors.horizontalCenter: parent.horizontalCenter
                width: 80
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: parent.isHovered = true
        onExited: parent.isHovered = false
        onClicked: launchApplication(appPath)
        onDoubleClicked: launchApplication(appPath)
    }

    function launchApplication(path) {
        StartMenuModel.launchApp(appId, path)
    }

    ToolTip {
        text: appName
        delay: 500
        visible: root.isHovered
        parent: root
        y: 72
        x: (96 - contentWidth) / 2
    }
}
