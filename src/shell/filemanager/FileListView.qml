import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ListView {
    id: fileListView

    property string currentPath: ""
    property int viewMode: 0 // 0=Details, 1=Tiles, 2=Content
    property string sortBy: "name"
    property bool sortDescending: false

    property var selectedPaths: []
    signal itemClicked(string itemPath, bool isDirectory)
    signal itemDoubleClicked(string itemPath, bool isDirectory)
    signal selectionChanged(var selectedPaths)

    clip: true
    cacheBuffer: 50
    snapMode: ListView.NoSnap

    // File items model (will be populated by backend)
    model: fileModel

    delegate: Loader {
        id: delegateLoader

        width: viewMode === 0 ? parent.width : 100
        height: viewMode === 0 ? 28 : (viewMode === 1 ? 90 : 60)

        sourceComponent: viewMode === 0 ? detailsDelegate :
                         viewMode === 1 ? tilesDelegate : contentDelegate

        // Details view delegate
        component DetailsDelegate {
            Item {
                id: detailsItem
                width: parent.width
                height: 28

                // Selection state
                property bool isSelected: selectedPaths.indexOf(model.path) !== -1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    spacing: 0

                    // Checkbox
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 4
                        color: isSelected ? accentColor : (detailsItemMouse.containsMouse ? hoverColor : "transparent")
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: isSelected ? "\u2713" : ""
                            color: "white"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: checkboxMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: toggleSelection(model.path)
                        }
                    }

                    // Icon
                    Image {
                        width: 16
                        height: 16
                        source: model.isDirectory ? "qrc:/icons/folder.svg" : FileManager.getFileIcon(model.path)
                        sourceSize: Qt.size(16, 16)
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 4
                    }

                    // Name
                    Text {
                        text: model.name
                        color: "#1F1F1F"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        elide: Text.ElideRight
                    }

                    // Spacer
                    Item { width: 60 }

                    // Size
                    Text {
                        text: model.isDirectory ? "" : formatSize(model.size)
                        color: "#666666"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                    }

                    // Date
                    Text {
                        text: formatDate(model.modified)
                        color: "#666666"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 180
                    }

                    // Type
                    Text {
                        text: model.isDirectory ? "文件夹" : model.fileType
                        color: "#666666"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150
                    }
                }

                // Hover background
                Rectangle {
                    anchors.fill: parent
                    color: detailsItemMouse.containsMouse ? hoverColor : "transparent"
                    visible: !isSelected
                }

                // Selection background
                Rectangle {
                    anchors.fill: parent
                    color: isSelected ? selectedColor : "transparent"
                    visible: isSelected
                }

                MouseArea {
                    id: detailsItemMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (event.modifiers & Qt.ControlModifier) {
                            toggleSelection(model.path)
                        } else {
                            clearSelection()
                            addSelection(model.path)
                        }
                        itemClicked(model.path, model.isDirectory)
                    }

                    onDoubleClicked: {
                        itemDoubleClicked(model.path, model.isDirectory)
                    }
                }
            }
        }

        // Tiles view delegate
        component TilesDelegate {
            Item {
                id: tileItem
                width: 100
                height: 90

                property bool isSelected: selectedPaths.indexOf(model.path) !== -1

                Rectangle {
                    anchors.centerIn: parent
                    width: 80
                    height: 80
                    radius: 4
                    color: tileMouse.containsMouse ? hoverColor : "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Image {
                            width: 48
                            height: 48
                            source: model.isDirectory ? "qrc:/icons/folder.svg" : FileManager.getFileIcon(model.path)
                            sourceSize: Qt.size(48, 48)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: model.name
                            color: "#1F1F1F"
                            font.pixelSize: 12
                            elide: Text.ElideMiddle
                            maximumLineCount: 2
                            width: 72
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: isSelected ? selectedColor : "transparent"
                    radius: 4
                    visible: isSelected
                }

                MouseArea {
                    id: tileMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (event.modifiers & Qt.ControlModifier) {
                            toggleSelection(model.path)
                        } else {
                            clearSelection()
                            addSelection(model.path)
                        }
                        itemClicked(model.path, model.isDirectory)
                    }

                    onDoubleClicked: {
                        itemDoubleClicked(model.path, model.isDirectory)
                    }
                }
            }
        }

        // Content view delegate
        component ContentDelegate {
            Item {
                id: contentItem
                width: parent.width
                height: 60

                property bool isSelected: selectedPaths.indexOf(model.path) !== -1

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    radius: 4
                    color: contentMouse.containsMouse ? hoverColor : "transparent"
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    spacing: 12

                    Image {
                        width: 40
                        height: 40
                        source: model.isDirectory ? "qrc:/icons/folder.svg" : FileManager.getFileIcon(model.path)
                        sourceSize: Qt.size(40, 40)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: model.name
                            color: "#1F1F1F"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        Text {
                            text: model.isDirectory ? "文件夹" : model.fileType + " - " + formatSize(model.size)
                            color: "#888888"
                            font.pixelSize: 12
                        }

                        Text {
                            text: "修改时间: " + formatDate(model.modified)
                            color: "#AAAAAA"
                            font.pixelSize: 11
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: isSelected ? selectedColor : "transparent"
                    visible: isSelected
                }

                MouseArea {
                    id: contentMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (event.modifiers & Qt.ControlModifier) {
                            toggleSelection(model.path)
                        } else {
                            clearSelection()
                            addSelection(model.path)
                        }
                        itemClicked(model.path, model.isDirectory)
                    }

                    onDoubleClicked: {
                        itemDoubleClicked(model.path, model.isDirectory)
                    }
                }
            }
        }
    }

    // Selection management
    function addSelection(path) {
        if (selectedPaths.indexOf(path) === -1) {
            selectedPaths.push(path)
            selectionChanged(selectedPaths)
        }
    }

    function removeSelection(path) {
        var index = selectedPaths.indexOf(path)
        if (index !== -1) {
            selectedPaths.splice(index, 1)
            selectionChanged(selectedPaths)
        }
    }

    function toggleSelection(path) {
        if (selectedPaths.indexOf(path) !== -1) {
            removeSelection(path)
        } else {
            addSelection(path)
        }
    }

    function clearSelection() {
        selectedPaths = []
        selectionChanged(selectedPaths)
    }

    // Utility functions
    function formatSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        else if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        else if (bytes < 1024 * 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + " MB"
        else return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB"
        return ""
    }

    function formatDate(timestamp) {
        if (!timestamp) return ""
        var date = new Date(timestamp * 1000)
        return date.toLocaleDateString() + " " + date.toLocaleTimeString()
    }

    // Theme colors
    readonly color accentColor: "#0078D4"
    readonly color hoverColor: "#E5E5E5"
    readonly color selectedColor: "#CCE4F7"

    // Placeholder for backend model
    ListModel {
        id: fileModel
    }
}
