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
    property bool isSelected: false

    width: 64
    height: 64

    Rectangle {
        id: background
        anchors.centerIn: parent
        width: 56
        height: 56
        radius: 8
        color: parent.isSelected ? selectedColor : (parent.isHovered ? hoverColor : "transparent")
        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        Column {
            anchors.centerIn: parent
            spacing: 4

            // App Icon
            Image {
                id: iconImage
                width: 32
                height: 32
                source: appIcon ? "image://icon/" + appIcon : "qrc:/icons/default-app.svg"
                sourceSize: Qt.size(32, 32)
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter

                // Fallback to initials
                Rectangle {
                    anchors.fill: parent
                    color: accentColor
                    radius: 6
                    visible: iconImage.status === Image.Error || iconImage.source === ""

                    Text {
                        anchors.centerIn: parent
                        text: appName.length > 0 ? appName[0].toUpperCase() : "?"
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }
            }

            // App Name
            Text {
                id: nameLabel
                text: appName
                color: textColor
                font.pixelSize: 11
                font.family: "Segoe UI"
                elide: Text.ElideRight
                maximumLineCount: 1
                anchors.horizontalCenter: parent.horizontalCenter
                width: 56
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            parent.isHovered = true
        }

        onExited: {
            parent.isHovered = false
        }

        onClicked: {
            launchApplication(appPath)
        }

        onDoubleClicked: {
            // Double-click also launches
            launchApplication(appPath)
        }
    }

    // Right-click context menu
    Menu {
        id: contextMenu

        MenuItem {
            text: "打开"
            onClicked: launchApplication(appPath)
        }

        MenuItem {
            text: "打开文件位置"
            onClicked: openFileLocation(appPath)
        }

        MenuSeparator {}

        MenuItem {
            text: "从列表中删除"
            onClicked: unpinApp(appId)
        }

        MenuItem {
            text: "属性"
            onClicked: showAppProperties(appId)
        }
    }

    ToolTip {
        text: appName
        delay: 500
        visible: parent.isHovered
        parent: root
        y: 68
        x: (64 - contentWidth) / 2
    }

    function launchApplication(path) {
        if (path) {
            StartMenuModel.launchApp(appId, path)
        }
    }

    function openFileLocation(path) {
        // Open file manager at the app's directory
        var dir = path.substring(0, path.lastIndexOf("/"))
        StartMenuModel.openFolder(dir)
    }

    function unpinApp(id) {
        StartMenuModel.unpinApp(id)
    }

    function showAppProperties(id) {
        StartMenuModel.showAppProperties(id)
    }

    readonly color hoverColor: "#E5E5E5"
    readonly color selectedColor: "#E0E0E0"
    readonly color accentColor: "#0078D4"
    readonly color textColor: "#1F1F1F"
}
