import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: breadcrumbBar

    property string currentPath: ""
    signal navigate(string path)

    height: 32
    color: "#F3F3F3"

    Row {
        id: breadcrumbRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        ListModel {
            id: pathSegments
        }

        ListView {
            id: pathView
            orientation: ListView.Horizontal
            model: pathSegments
            height: parent.height
            clip: true

            delegate: Rectangle {
                id: segment
                height: 28
                color: "transparent"
                radius: 4

                property bool isLast: index === pathSegments.count - 1

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: model.name
                        color: isLast ? "#1F1F1F" : "#0078D4"
                        font.pixelSize: 13
                        font.weight: isLast ? Font.Medium : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "/"
                        color: "#888888"
                        font.pixelSize: 13
                        visible: !isLast
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#E5E5E5"
                    onExited: parent.color = "transparent"
                    onClicked: {
                        // Navigate to this path
                        var targetPath = ""
                        for (var i = 0; i <= index; i++) {
                            targetPath += "/" + pathSegments.get(i).name
                        }
                        if (targetPath === "//") targetPath = "/"
                        breadcrumbBar.navigate(targetPath)
                    }
                }
            }
        }
    }

    // Update path segments when path changes
    onCurrentPathChanged: {
        updatePathSegments()
    }

    Component.onCompleted: {
        updatePathSegments()
    }

    function updatePathSegments() {
        pathSegments.clear()

        var cleanPath = currentPath.replace("file://", "")
        if (!cleanPath || cleanPath === "/") {
            pathSegments.append({ name: "此电脑" })
            return
        }

        var parts = cleanPath.split("/").filter(function(p) { return p.length > 0 })

        // Add "此电脑" at the start
        pathSegments.append({ name: "此电脑" })

        // Add each path segment
        var runningPath = ""
        for (var i = 0; i < parts.length; i++) {
            runningPath += "/" + parts[i]
            pathSegments.append({ name: parts[i] })
        }
    }
}
