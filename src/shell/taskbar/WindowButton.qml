import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: windowButton

    property int windowId: 0
    property string windowTitle: ""
    property string windowIcon: ""
    property bool isActive: false
    property bool isHovered: false
    property int clickCount: 0
    property int lastClickTime: 0

    width: 180
    height: 40

    // Double-click detection
    readonly property int doubleClickThreshold: 400 // ms

    Rectangle {
        id: background
        anchors.centerIn: parent
        width: parent.isActive ? 176 : 168
        height: 36
        radius: 8
        color: parent.isActive ? "#4D4D4D" : (parent.isHovered ? "#383838" : "transparent")
        Behavior on color {
            ColorAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
        Behavior on width {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            // Window Icon
            Image {
                id: iconImage
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                source: windowIcon ? "image://icon/" + windowIcon : "qrc:/icons/window-default.svg"
                sourceSize: Qt.size(16, 16)
                fillMode: Image.PreserveAspectFit

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    visible: iconImage.status === Image.Error

                    Text {
                        anchors.centerIn: parent
                        text: "W"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                }
            }

            // Window Title
            Text {
                id: titleText
                Layout.fillWidth: true
                text: windowTitle
                elide: Text.ElideRight
                color: parent.parent.parent.isActive ? "#FFFFFF" : "#AAAAAA"
                font.pixelSize: 12
                font.family: "Segoe UI"
                verticalAlignment: Text.AlignVCenter
            }

            // Close button (appears on hover)
            Rectangle {
                id: closeButton
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 4
                color: parent.parent.parent.isHovered ? "#E81123" : "transparent"
                visible: parent.parent.parent.isHovered

                Text {
                    anchors.centerIn: parent
                    text: "\u2715"
                    color: "white"
                    font.pixelSize: 10
                }

                MouseArea {
                    id: closeButtonMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#F1707A"
                    onExited: parent.color = "#E81123"
                    onClicked: {
                        TaskbarModel.closeWindow(windowId)
                        mouse.accepted = true
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }
        }

        // Active window indicator (Windows 11 style accent bar)
        Rectangle {
            id: activeIndicator
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            width: parent.width
            height: 3
            radius: 0
            color: accentColor
            visible: parent.parent.isActive
        }
    }

    // Mouse handling
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: parent.isHovered = true
        onExited: parent.isHovered = false

        onClicked: {
            var currentTime = Date.now()
            if (currentTime - lastClickTime < doubleClickThreshold && clickCount === 1) {
                // Double-click: maximize/restore window
                TaskbarModel.maximizeWindow(windowId)
                clickCount = 0
                lastClickTime = 0
            } else {
                // Single-click: activate window
                TaskbarModel.activateWindow(windowId)
                clickCount = 1
                lastClickTime = currentTime

                // Reset after threshold
                resetClickTimer.restart()
            }
        }
    }

    // Timer to reset click state
    Timer {
        id: resetClickTimer
        interval: windowButton.doubleClickThreshold
        onTriggered: {
            clickCount = 0
            lastClickTime = 0
        }
    }

    // Tooltip
    ToolTip {
        text: windowTitle
        delay: 500
        visible: windowButton.isHovered
        parent: windowButton
        y: -45
        x: 0
    }

    // Constants
    readonly color accentColor: "#0078D4"
}
