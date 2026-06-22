import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: pinnedItem

    property string appId: ""
    property string appName: ""
    property string appIcon: ""
    property string appPath: ""
    property bool isHovered: false
    property bool isActive: false

    width: 44
    height: 40

    Rectangle {
        id: background
        anchors.centerIn: parent
        width: 40
        height: 40
        radius: 8
        color: parent.isActive ? accentColor : (parent.isHovered ? hoverColor : "transparent")
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }

        // App Icon
        Image {
            id: iconImage
            anchors.centerIn: parent
            width: 24
            height: 24
            source: appIcon ? "image://icon/" + appIcon : "qrc:/icons/default-app.svg"
            sourceSize: Qt.size(24, 24)
            fillMode: Image.PreserveAspectFit

            // Fallback to initials if icon not found
            Rectangle {
                anchors.fill: parent
                color: accentColor
                radius: 4
                visible: iconImage.status === Image.Error || iconImage.source === ""

                Text {
                    anchors.centerIn: parent
                    text: appName.length > 0 ? appName[0].toUpperCase() : "?"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }

        // Hover indicator line at bottom (Windows 11 style)
        Rectangle {
            id: hoverIndicator
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            width: 20
            height: 3
            radius: 1.5
            color: accentColor
            visible: parent.isHovered && !parent.isActive
        }

        // Active indicator
        Rectangle {
            id: activeIndicator
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            width: 20
            height: 3
            radius: 1.5
            color: accentColor
            visible: parent.isActive
        }
    }

    // Mouse handling
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onEntered: parent.isHovered = true
        onExited: parent.isHovered = false

        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                launchApplication(appPath)
            } else if (mouse.button === Qt.MiddleButton) {
                closeApplication(appId)
            }
        }

        onPressAndHold: {
            // Right-click context menu
            showAppContextMenu(appId, appPath)
        }
    }

    // Tooltip
    ToolTip {
        text: appName
        delay: 500
        visible: parent.isHovered && !startMenuOpen
        parent: pinnedItem
        y: -40
        x: (parent.width - contentWidth) / 2
    }

    // Functions
    function launchApplication(path) {
        TaskbarModel.launchApp(appId, path)
    }

    function closeApplication(id) {
        TaskbarModel.closeApp(id)
    }

    function showAppContextMenu(id, path) {
        appContextMenu.open(id, path)
    }

    // Constants
    readonly color hoverColor: "#3D3D3D"
    readonly color accentColor: "#0078D4"
}
