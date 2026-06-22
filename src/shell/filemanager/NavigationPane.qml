import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: navPane

    property string currentPath: ""
    signal navigate(string path)

    color: "#FAFAFA"

    ListView {
        id: navList
        anchors.fill: parent
        anchors.topMargin: 8
        clip: true
        spacing: 2

        // Quick access section
        SectionHeader {
            text: "快速访问"
            width: parent.width
        }

        // Home
        NavItem {
            icon: "\uD83C\uDFE0"
            text: "主文件夹"
            path: "file:///home/" + userName
            isSelected: currentPath === "file:///home/" + userName
            onClicked: navigate(path)
        }

        // Desktop
        NavItem {
            icon: "\uD83D\uDCBB"
            text: "桌面"
            path: "file:///home/" + userName + "/Desktop"
            isSelected: currentPath === "file:///home/" + userName + "/Desktop"
            onClicked: navigate(path)
        }

        // Downloads
        NavItem {
            icon: "\u2B07"
            text: "下载"
            path: "file:///home/" + userName + "/Downloads"
            isSelected: currentPath === "file:///home/" + userName + "/Downloads"
            onClicked: navigate(path)
        }

        // Documents
        NavItem {
            icon: "\uD83D\uDCC4"
            text: "文档"
            path: "file:///home/" + userName + "/Documents"
            isSelected: currentPath === "file:///home/" + userName + "/Documents"
            onClicked: navigate(path)
        }

        // Pictures
        NavItem {
            icon: "\uD83D\uDDBC"
            text: "图片"
            path: "file:///home/" + userName + "/Pictures"
            isSelected: currentPath === "file:///home/" + userName + "/Pictures"
            onClicked: navigate(path)
        }

        // Music
        NavItem {
            icon: "\uD83C\uDFB5"
            text: "音乐"
            path: "file:///home/" + userName + "/Music"
            isSelected: currentPath === "file:///home/" + userName + "/Music"
            onClicked: navigate(path)
        }

        // Videos
        NavItem {
            icon: "\uD83C\uDFAC"
            text: "视频"
            path: "file:///home/" + userName + "/Videos"
            isSelected: currentPath === "file:///home/" + userName + "/Videos"
            onClicked: navigate(path)
        }

        // Separator
        Rectangle {
            height: 1
            color: "#E0E0E0"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
        }

        // This PC
        NavItem {
            icon: "\uD83D\uDCC1"
            text: "此电脑"
            path: "file:///"
            isSelected: currentPath === "file:///"
            onClicked: navigate(path)
        }

        // Windows drives (when dual boot detected)
        SectionHeader {
            text: "Windows 分区"
            width: parent.width
            visible: windowsDrives.length > 0
        }

        // Windows partitions
        Repeater {
            model: windowsDrives
            delegate: NavItem {
                icon: "\uD83D\uDCBE"
                text: modelData.label || ("本地磁盘 (" + modelData.mountPoint + ")")
                path: modelData.mountPoint
                isSelected: currentPath === modelData.mountPoint
                onClicked: navigate(path)
            }
        }

        // Separator before Network
        Rectangle {
            height: 1
            color: "#E0E0E0"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
        }

        // Network
        NavItem {
            icon: "\uD83D\uDCF6"
            text: "网络"
            path: "network://"
            isSelected: currentPath === "network://"
            onClicked: navigate(path)
        }
    }

    // Model data
    property var windowsDrives: []

    // Load Windows drives on startup
    Component.onCompleted: {
        loadWindowsDrives()
    }

    function loadWindowsDrives() {
        windowsDrives = FileManager.getWindowsDrives()
    }

    property string userName: "user"
}

// Section header component
Rectangle {
    id: sectionHeader

    property string text: ""

    height: 28
    color: "transparent"

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        text: parent.text
        color: "#666666"
        font.pixelSize: 11
        font.weight: Font.Medium
    }
}

// Navigation item component
Rectangle {
    id: navItem

    property string icon: ""
    property string text: ""
    property string path: ""
    property bool isSelected: false
    signal clicked()

    height: 32
    color: isSelected ? "#E0E0E0" : "transparent"
    radius: 4

    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined
    anchors.leftMargin: 8
    anchors.rightMargin: 8

    Row {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 10

        Text {
            text: icon
            font.pixelSize: 14
            width: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: parent.parent.text
            color: "#1F1F1F"
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: if (!isSelected) parent.color = "#E5E5E5"
        onExited: parent.color = isSelected ? "#E0E0E0" : "transparent"
        onClicked: clicked()
    }
}
