import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ListView {
    id: allAppsView

    property var categories: [
        { name: "常用", icon: "\u2B50", apps: [] },
        { name: "工具", icon: "\u2699\uFE0F", apps: [] },
        { name: "娱乐", icon: "\uD83C\uDFAE", apps: [] },
        { name: "开发", icon: "\uD83D\uDCBB", apps: [] },
        { name: "系统", icon: "\uD83D\uDCDA", apps: [] }
    ]

    model: categories
    spacing: 0
    clip: true

    header: Rectangle {
        width: parent.width
        height: 40
        color: "transparent"

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 24
            spacing: 24

            Repeater {
                model: categories

                Rectangle {
                    id: categoryTab
                    height: 32
                    radius: 4
                    color: currentCategory === index ? "#E0E0E0" : "transparent"
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        text: modelData.name
                        color: currentCategory === index ? textColor : secondaryTextColor
                        font.pixelSize: 13
                        font.weight: currentCategory === index ? Font.Medium : Font.Normal
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = "#EEEEEE"
                        onExited: parent.color = currentCategory === index ? "#E0E0E0" : "transparent"
                        onClicked: {
                            currentCategory = index
                        }
                    }
                }
            }
        }
    }

    // Category tabs state
    property int currentCategory: 0
    readonly color textColor: "#1F1F1F"
    readonly color secondaryTextColor: "#666666"

    // Apps list by category
    Rectangle {
        id: appsContainer
        anchors.top: parent.header
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "transparent"

        // Grid of apps for selected category
        GridView {
            id: appsGrid
            anchors.fill: parent
            anchors.margins: 24
            cellWidth: 100
            cellHeight: 90
            model: categories[currentCategory].apps
            delegate: AllAppsItem {
                appId: modelData.appId
                appName: modelData.name
                appIcon: modelData.icon
                appPath: modelData.path
            }
            clip: true
            scrollBarPolicy: ScrollBarPolicy.AsNeeded
        }
    }
}
