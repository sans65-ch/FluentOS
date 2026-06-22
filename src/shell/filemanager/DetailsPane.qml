import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: detailsPane

    property var selectedItems: []

    color: "#FAFAFA"

    Column {
        anchors.fill: parent
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        spacing: 16

        // Preview area
        Rectangle {
            id: previewArea
            width: parent.width
            height: 200
            color: "#EEEEEE"
            radius: 4

            Image {
                id: previewImage
                anchors.centerIn: parent
                width: parent.width - 32
                height: parent.height - 32
                fillMode: Image.P-contain
                source: selectedItems.length === 1 ? FileManager.getFilePreview(selectedItems[0]) : ""
                visible: status === Image.Ready

                Rectangle {
                    anchors.fill: parent
                    color: "#DDDDDD"
                    visible: previewImage.status === Image.Error || previewImage.source === ""
                }

                // Folder icon for directories
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: previewImage.source === ""

                    Text {
                        text: "\uD83D\uDCC1"
                        font.pixelSize: 64
                        color: "#AAAAAA"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: selectedItems.length === 1 ? getFileName(selectedItems[0]) : selectedItems.length + " 个项目"
                        color: "#888888"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // File info
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8

            Text {
                text: selectedItems.length === 1 ? getFileName(selectedItems[0]) : selectedItems.length + " 个项目"
                color: "#1F1F1F"
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideMiddle
            }

            Text {
                text: selectedItems.length === 1 ? getFileType(selectedItems[0]) : ""
                color: "#666666"
                font.pixelSize: 12
            }
        }

        // Divider
        Rectangle {
            height: 1
            color: "#E0E0E0"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
        }

        // Properties
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            PropertyRow {
                label: "大小"
                value: selectedItems.length === 1 ? (getFileSize(selectedItems[0])) : calculateTotalSize()
            }

            PropertyRow {
                label: "包含"
                value: selectedItems.length === 1 ? getItemCount(selectedItems[0]) : ""
            }

            PropertyRow {
                label: "位置"
                value: selectedItems.length === 1 ? getFilePath(selectedItems[0]) : ""
            }

            PropertyRow {
                label: "创建时间"
                value: selectedItems.length === 1 ? getFileCreated(selectedItems[0]) : ""
            }

            PropertyRow {
                label: "修改时间"
                value: selectedItems.length === 1 ? getFileModified(selectedItems[0]) : ""
            }

            PropertyRow {
                label: "访问时间"
                value: selectedItems.length === 1 ? getFileAccessed(selectedItems[0]) : ""
            }
        }

        // Divider
        Rectangle {
            height: 1
            color: "#E0E0E0"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
        }

        // Action buttons
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8

            Button {
                width: parent.width
                text: "打开"
                onClicked: {
                    if (selectedItems.length === 1) {
                        FileManager.openFile(selectedItems[0])
                    }
                }
            }

            Button {
                width: parent.width
                text: "打开文件位置"
                onClicked: {
                    if (selectedItems.length === 1) {
                        FileManager.showInFolder(selectedItems[0])
                    }
                }
            }
        }
    }

    // Helper functions
    function getFileName(path) {
        return path.split("/").pop()
    }

    function getFilePath(path) {
        return path.substring(0, path.lastIndexOf("/"))
    }

    function getFileType(path) {
        return FileManager.getFileType(path)
    }

    function getFileSize(path) {
        var size = FileManager.getFileSize(path)
        if (size < 0) return ""
        return formatSize(size)
    }

    function getItemCount(path) {
        return FileManager.getItemCount(path)
    }

    function getFileCreated(path) {
        return FileManager.getFileCreated(path)
    }

    function getFileModified(path) {
        return FileManager.getFileModified(path)
    }

    function getFileAccessed(path) {
        return FileManager.getFileAccessed(path)
    }

    function calculateTotalSize() {
        var total = 0
        for (var i = 0; i < selectedItems.length; i++) {
            var size = FileManager.getFileSize(selectedItems[i])
            if (size > 0) total += size
        }
        return formatSize(total)
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        else if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        else if (bytes < 1024 * 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + " MB"
        else return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB"
        return ""
    }
}

// Property row component
Row {
    property string label: ""
    property string value: ""

    Text {
        text: label
        color: "#666666"
        font.pixelSize: 12
        width: 80
    }

    Text {
        text: parent.value
        color: "#1F1F1F"
        font.pixelSize: 12
        elide: Text.ElideMiddle
    }
}
