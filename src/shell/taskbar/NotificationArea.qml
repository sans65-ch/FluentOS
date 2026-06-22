import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Item {
    id: notificationArea

    property var notifications: []
    property int maxNotifications: 50

    signal notificationAdded(var notification)
    signal notificationRemoved(int index)

    ListModel {
        id: notificationModel
    }

    // Notification bubble component
    Component {
        id: notificationBubble

        Rectangle {
            id: bubble
            width: 360
            height: contentColumn.height + 16
            radius: 8
            color: "#2D2D2D"
            border.width: 1
            border.color: "#3D3D3D"

            // Shadow effect
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 4
                radius: 8
                color: "#40000000"
            }

            Column {
                id: contentColumn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 12
                spacing: 8

                // Header row
                RowLayout {
                    width: parent.width
                    spacing: 8

                    // App icon
                    Image {
                        id: appIcon
                        width: 16
                        height: 16
                        source: model.appIcon || "qrc:/icons/default-app.svg"
                    }

                    // App name
                    Text {
                        text: model.appName || "应用"
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    // Time
                    Text {
                        text: model.time || ""
                        color: "#888888"
                        font.pixelSize: 11
                    }

                    // Close button
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 4
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "\u2715"
                            color: "#888888"
                            font.pixelSize: 10
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = "#3D3D3D"
                            onExited: parent.color = "transparent"
                            onClicked: dismissNotification(model.index)
                        }
                    }
                }

                // Title
                Text {
                    width: parent.width
                    text: model.title || ""
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    wrapMode: Text.WordWrap
                    visible: model.title
                }

                // Body
                Text {
                    width: parent.width
                    text: model.body || ""
                    color: "#CCCCCC"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    visible: model.body
                }

                // Action buttons
                Row {
                    spacing: 8
                    visible: model.actions && model.actions.length > 0

                    Repeater {
                        model: model.actions || []

                        Button {
                            text: modelData.label
                            onClicked: {
                                executeAction(model.index, modelData.action)
                            }
                        }
                    }
                }
            }

            // Progress bar (for progress notifications)
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 4
                radius: 0
                color: "#3D3D3D"
                visible: model.progress !== undefined && model.progress >= 0

                Rectangle {
                    width: parent.width * (model.progress / 100)
                    height: parent.height
                    color: "#0078D4"
                }
            }

            // Animation
            NumberAnimation {
                id: slideIn
                target: bubble
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                id: slideOut
                target: bubble
                property: "opacity"
                from: 1
                to: 0
                duration: 150
                easing.type: Easing.InQuad
            }

            Component.onCompleted: {
                slideIn.start()
            }
        }
    }

    function addNotification(notification) {
        if (notifications.length >= maxNotifications) {
            removeNotification(0)
        }

        notification.index = notifications.length
        notification.time = new Date().toLocaleTimeString()
        notifications.append(notification)
        notificationModel.append(notification)
        notificationAdded(notification)
    }

    function removeNotification(index) {
        if (index >= 0 && index < notifications.length) {
            var removed = notifications[index]
            notifications.splice(index, 1)
            notificationModel.remove(index)
            notificationRemoved(index)
            return removed
        }
        return null
    }

    function dismissNotification(index) {
        var notification = removeNotification(index)
        if (notification && notification.onDismiss) {
            notification.onDismiss()
        }
    }

    function clearAll() {
        notifications.clear()
        notificationModel.clear()
    }

    function executeAction(notificationIndex, action) {
        var notification = notifications[notificationIndex]
        if (notification && notification.onAction) {
            notification.onAction(action)
        }
    }

    // Example: Add a test notification
    function showTestNotification() {
        addNotification({
            appName: "FluentOS",
            appIcon: "qrc:/icons/logo.svg",
            title: "通知测试",
            body: "这是一个测试通知",
            actions: [
                { label: "打开", action: "open" },
                { label: "忽略", action: "dismiss" }
            ]
        })
    }
}
