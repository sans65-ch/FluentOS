import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: controlPanel

    title: "设置"
    width: 900
    height: 650
    minimumWidth: 800
    minimumHeight: 550

    // Theme colors
    readonly color accentColor: "#0078D4"
    readonly color backgroundColor: "#F3F3F3"
    readonly color surfaceColor: "#FFFFFF"
    readonly color hoverColor: "#E5E5E5"
    readonly color selectedColor: "#CCE4F7"
    readonly color textColor: "#1F1F1F"
    readonly color secondaryTextColor: "#666666"

    // Current category
    property string currentCategory: "system"
    property string currentPage: ""

    // Categories
    property var categories: [
        { id: "system", name: "系统", icon: "\uD83D\uDCDA", subcategories: [
            { id: "about", name: "关于" },
            { id: "display", name: "显示" },
            { id: "sound", name: "声音" },
            { id: "notifications", name: "通知" },
            { id: "power", name: "电源" }
        ]},
        { id: "devices", name: "设备", icon: "\uD83D\uDDBF", subcategories: [
            { id: "bluetooth", name: "蓝牙" },
            { id: "printers", name: "打印机和扫描仪" },
            { id: "mouse", name: "鼠标" },
            { id: "keyboard", name: "键盘" }
        ]},
        { id: "network", name: "网络和Internet", icon: "\uD83D\uDCF6", subcategories: [
            { id: "wifi", name: "WLAN" },
            { id: "ethernet", name: "以太网" },
            { id: "vpn", name: "VPN" },
            { id: "proxy", name: "代理" }
        ]},
        { id: "personalization", name: "个性化", icon: "\u2728", subcategories: [
            { id: "background", name: "背景" },
            { id: "colors", name: "颜色" },
            { id: "themes", name: "主题" },
            { id: "fonts", name: "字体" }
        ]},
        { id: "apps", name: "应用", icon: "\uD83D\uDD27", subcategories: [
            { id: "installed", name: "已安装的应用" },
            { id: "default", name: "默认应用" },
            { id: "startup", name: "启动" }
        ]},
        { id: "accounts", name: "账户", icon: "\uD83D\uDC64", subcategories: [
            { id: "your-info", name: "你的信息" },
            { id: "email", name: "电子邮件和账户" },
            { id: "sync", name: "同步" }
        ]},
        { id: "time", name: "时间和语言", icon: "\u23F0", subcategories: [
            { id: "region", name: "区域和语言" },
            { id: "date", name: "日期和时间" },
            { id: "speech", name: "语音" }
        ]},
        { id: "accessibility", name: "辅助功能", icon: "\uD83C\uDF47", subcategories: [
            { id: "vision", name: "视觉" },
            { id: "hearing", name: "听觉" },
            { id: "interaction", name: "交互" }
        ]},
        { id: "security", name: "隐私和安全性", icon: "\uD83D\uDD12", subcategories: [
            { id: "security-center", name: "安全性与维护" },
            { id: "firewall", name: "防火墙" },
            { id: "updates", name: "Windows 更新" }
        ]},
        { id: "update", name: "Windows 更新", icon: "\uD83D\uDD04", subcategories: [
            { id: "windows-update", name: "Windows 更新" }
        ]}
    ]

    header: ToolBar {
        id: toolBar
        height: 48
        background: Rectangle { color: surfaceColor }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            spacing: 16

            // Search box
            Rectangle {
                width: 300
                height: 36
                radius: 4
                color: backgroundColor
                border.width: 1
                border.color: "#E0E0E0"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 8

                    Text {
                        text: "\uD83D\uDD0D"
                        font.pixelSize: 14
                        color: "#888888"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id: searchInput
                        width: 260
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        placeholderText: "搜索设置"
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // User avatar
            CircleAvatar {
                id: userAvatar
                size: 32
                name: userName
            }
        }
    }

    // Main content
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left navigation panel
        Rectangle {
            id: navPanel
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: backgroundColor

            ListView {
                id: categoryList
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                clip: true
                spacing: 2

                model: categories

                delegate: Rectangle {
                    id: categoryItem
                    width: categoryList.width
                    height: 44
                    color: currentCategory === modelData.id ? selectedColor : "transparent"
                    radius: 4
                    anchors.left: parent ? parent.left : undefined
                    anchors.right: parent ? parent.right : undefined
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    property bool expanded: currentCategory === modelData.id

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: 18
                            width: 24
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Text {
                                text: modelData.name
                                color: textColor
                                font.pixelSize: 13
                                font.weight: expanded ? Font.Medium : Font.Normal
                            }

                            Text {
                                text: modelData.subcategories[0] ? modelData.subcategories[0].name : ""
                                color: secondaryTextColor
                                font.pixelSize: 11
                                visible: !expanded && modelData.subcategories.length > 0
                            }
                        }
                    }

                    // Expand to show subcategories
                    Rectangle {
                        id: subcategoryPanel
                        anchors.top: parent.bottom
                        width: categoryList.width - 16
                        x: 8
                        color: backgroundColor
                        radius: 4
                        visible: expanded

                        Column {
                            anchors.fill: parent
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4
                            spacing: 2

                            Repeater {
                                model: modelData.subcategories

                                delegate: Rectangle {
                                    id: subItem
                                    width: subcategoryPanel.width
                                    height: 36
                                    color: currentPage === modelData.id ? hoverColor : "transparent"
                                    radius: 4
                                    anchors.left: parent ? parent.left : undefined
                                    anchors.right: parent ? parent.right : undefined
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 8

                                    Text {
                                        text: modelData.name
                                        color: currentPage === modelData.id ? accentColor : textColor
                                        font.pixelSize: 13
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 32
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: if (currentPage !== modelData.id) parent.color = hoverColor
                                        onExited: parent.color = currentPage === modelData.id ? hoverColor : "transparent"
                                        onClicked: {
                                            currentPage = modelData.id
                                            loadPage(modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: if (currentCategory !== modelData.id) parent.color = hoverColor
                        onExited: parent.color = currentCategory === modelData.id ? selectedColor : "transparent"
                        onClicked: {
                            currentCategory = modelData.id
                            if (modelData.subcategories.length > 0) {
                                currentPage = modelData.subcategories[0].id
                                loadPage(currentPage)
                            }
                        }
                    }
                }
            }
        }

        // Right content panel
        Rectangle {
            id: contentPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: surfaceColor

            // Page title
            Rectangle {
                id: pageHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 60
                color: "transparent"

                Text {
                    id: pageTitle
                    text: currentPage ? getCategoryName(currentCategory) + " > " + getPageName(currentPage) : ""
                    color: textColor
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Page content (placeholder)
            ScrollView {
                id: pageContent
                anchors.top: pageHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                anchors.bottomMargin: 16
                clip: true

                // This will be replaced by actual page content
                Column {
                    spacing: 24

                    // Placeholder content for "About" page
                    placeholder: [
                        { title: "设备名称", value: deviceName, editable: true },
                        { title: "设备规格", value: "FluentOS 1.0.0" },
                        { title: "处理器", value: systemInfo.processor },
                        { title: "已安装的内存", value: systemInfo.memory },
                        { title: "系统类型", value: systemInfo.systemType },
                        { title: "Windows 版本", value: systemInfo.windowsVersion }
                    ]
                }
            }
        }
    }

    // User data
    property string userName: "User"

    // System info
    property var systemInfo: ({
        processor: "Intel Core i3-4xxx",
        memory: "4.00 GB",
        systemType: "64位操作系统",
        windowsVersion: "FluentOS 1.0.0"
    })

    property string deviceName: "FLUENTOS-PC"

    // Functions
    function loadPage(pageId) {
        console.log("Loading page:", pageId)
        // Load the appropriate settings page
    }

    function getCategoryName(categoryId) {
        for (var i = 0; i < categories.length; i++) {
            if (categories[i].id === categoryId) {
                return categories[i].name
            }
        }
        return ""
    }

    function getPageName(pageId) {
        for (var i = 0; i < categories.length; i++) {
            var subs = categories[i].subcategories
            for (var j = 0; j < subs.length; j++) {
                if (subs[j].id === pageId) {
                    return subs[j].name
                }
            }
        }
        return ""
    }
}

// Circle avatar component
Rectangle {
    id: circleAvatar

    property string name: ""
    property string imageSource: ""
    property int size: 40

    width: size
    height: size
    radius: size / 2
    color: accentColor

    Text {
        text: name.length > 0 ? name[0].toUpperCase() : "?"
        color: "white"
        font.pixelSize: size * 0.4
        font.bold: true
        anchors.centerIn: parent
    }
}
