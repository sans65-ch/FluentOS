import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ListView {
    id: searchResults

    property string searchQuery: ""
    property var results: []

    // Perform search when query changes
    onSearchQueryChanged: {
        performSearch(searchQuery)
    }

    clip: true
    spacing: 2

    // Results count header
    Rectangle {
        id: header
        width: parent.width
        height: 32
        color: "transparent"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            text: "最佳匹配"
            color: "#666666"
            font.pixelSize: 12
        }
    }

    // Results list
    model: results

    delegate: Rectangle {
        id: resultItem
        width: parent.width
        height: 48
        color: parent.ListView.isCurrentItem ? "#E5E5E5" : "transparent"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color = "#F0F0F0"
            onExited: parent.color = parent.ListView.isCurrentItem ? "#E5E5E5" : "transparent"
            onClicked: {
                ListView.view.currentIndex = index
                launchApplication(modelData.path)
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 12

            // App icon
            Image {
                id: iconImage
                width: 24
                height: 24
                source: modelData.icon || "qrc:/icons/default-app.svg"
                sourceSize: Qt.size(24, 24)
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    color: "#0078D4"
                    radius: 4
                    visible: iconImage.status === Image.Error || iconImage.source === ""

                    Text {
                        anchors.centerIn: parent
                        text: modelData.name ? modelData.name[0].toUpperCase() : "?"
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                // App name with highlight
                Text {
                    id: nameText
                    text: modelData.name || ""
                    color: "#1F1F1F"
                    font.pixelSize: 13
                }

                // Path
                Text {
                    text: modelData.path || ""
                    color: "#888888"
                    font.pixelSize: 11
                    elide: Text.ElideLeft
                }
            }
        }
    }

    // Empty state
    Rectangle {
        anchors.centerIn: parent
        width: 200
        height: 100
        color: "transparent"
        visible: results.length === 0 && searchQuery !== ""

        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "\uD83D\uDD0D"
                font.pixelSize: 32
                color: "#CCCCCC"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "未找到结果"
                color: "#888888"
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "\"" + searchQuery + "\""
                color: "#AAAAAA"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    function performSearch(query) {
        if (!query || query.length < 2) {
            results = []
            return
        }

        // Search using StartMenuModel
        results = StartMenuModel.search(query)
    }

    function launchApplication(path) {
        if (path) {
            StartMenuModel.launchApp("", path)
        }
    }
}
