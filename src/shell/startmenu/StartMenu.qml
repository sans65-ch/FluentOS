import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Rectangle {
    id: startMenu

    property bool isOpen: false
    property int selectedIndex: -1

    // Dimensions
    readonly property int menuWidth: 600
    readonly property int menuHeight: 680
    readonly property int pinnedWidth: 240

    // Colors
    readonly color backgroundColor: root.effectEnabled ? "#F3F3F3" : "#F9F9F9"
    readonly color surfaceColor: "#FFFFFF"
    readonly color hoverColor: "#E5E5E5"
    readonly color selectedColor: "#E0E0E0"
    readonly color accentColor: "#0078D4"
    readonly color textColor: "#1F1F1F"
    readonly color secondaryTextColor: "#666666"

    // Animation
    readonly property int animationDuration: 200

    width: menuWidth
    height: menuHeight
    visible: isOpen
    radius: 8

    // Shadow
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 4
        radius: 8
        color: "#30000000"
    }

    // Blur background when supported
    layer.blendMode: StackView.Discard

    // Position: below taskbar, aligned to left
    anchors {
        left: parent.left
        leftMargin: 8
        bottom: parent.top
        bottomMargin: -8
    }

    // Clip contents to rounded rectangle
    clip: true

    // Hide when clicked outside
    MouseArea {
        anchors.fill: parent
        enabled: isOpen
        onClicked: {
            // Don't close on internal clicks
        }
    }

    contentData: [
        RowLayout {
            anchors.fill: parent

            // === LEFT PINNED APPS ===
            Rectangle {
                id: leftPanel
                Layout.preferredWidth: pinnedWidth
                Layout.fillHeight: true
                color: backgroundColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 24
                    spacing: 2

                    // Search box
                    SearchBox {
                        id: searchBox
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: pinnedWidth - 32
                    }

                    // Pinned section header
                    Item {
                        Layout.preferredHeight: 32
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16

                        Text {
                            text: "已固定"
                            color: secondaryTextColor
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Pin/Unpin all button
                        Rectangle {
                            anchors.right: parent.right
                            width: 20
                            height: 20
                            radius: 4
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\u2699"
                                color: secondaryTextColor
                                font.pixelSize: 14
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = hoverColor
                                onExited: parent.color = "transparent"
                                onClicked: editPinnedApps()
                            }
                        }
                    }

                    // Pinned apps grid
                    GridView {
                        id: pinnedGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        cellWidth: 72
                        cellHeight: 72
                        model: StartMenuModel.pinnedApps
                        delegate: PinnedAppTile {
                            appId: model.appId
                            appName: model.name
                            appIcon: model.icon
                            appPath: model.path
                        }
                        clip: true
                        interactive: true
                        scrollBarPolicy: ScrollBarPolicy.AsNeeded
                    }

                    // Recommended section (below pinned)
                    Item {
                        Layout.preferredHeight: 32
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        visible: false // Hidden by default

                        Text {
                            text: "推荐"
                            color: secondaryTextColor
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // User profile
                    Item {
                        Layout.preferredHeight: 48
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.bottomMargin: 8

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 12

                                // User avatar
                                CircleAvatar {
                                    id: userAvatar
                                    size: 32
                                    name: userName
                                    imageSource: userAvatarImage
                                }

                                // User name
                                Text {
                                    text: userName
                                    color: textColor
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    Layout.verticalCenter: parent.verticalCenter
                                }

                                Item { Layout.fillWidth: true }

                                // Power button
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 4
                                    color: "transparent"

                                    Text {
                                        text: "\u23FB"
                                        font.pixelSize: 14
                                        color: textColor
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = hoverColor
                                        onExited: parent.color = "transparent"
                                        onClicked: showPowerMenu()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // === RIGHT CONTENT AREA ===
            Rectangle {
                id: rightPanel
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: surfaceColor

                // Top bar with user info and search
                Rectangle {
                    id: topBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 64
                    color: "transparent"

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        spacing: 4

                        Text {
                            text: userName
                            color: textColor
                            font.pixelSize: 24
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "祝你每天都愉快"
                            color: secondaryTextColor
                            font.pixelSize: 12
                        }
                    }
                }

                // Content based on selection
                Item {
                    id: contentArea
                    anchors.top: topBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    // Default: All apps view
                    AllAppsView {
                        id: allAppsView
                        anchors.fill: parent
                        visible: searchBox.text === ""
                    }

                    // Search results
                    SearchResults {
                        id: searchResults
                        anchors.fill: parent
                        visible: searchBox.text !== ""
                        searchQuery: searchBox.text
                    }
                }
            }
        }
    ]

    // Open animation
    NumberAnimation {
        id: openAnimation
        target: startMenu
        property: "opacity"
        from: 0
        to: 1
        duration: animationDuration
        easing.type: Easing.OutQuad
    }

    // Close animation
    NumberAnimation {
        id: closeAnimation
        target: startMenu
        property: "opacity"
        from: 1
        to: 0
        duration: animationDuration
        easing.type: Easing.InQuad
        onStopped: {
            isOpen = false
        }
    }

    function open() {
        isOpen = true
        openAnimation.start()
        searchBox.forceActiveFocus()
    }

    function close() {
        closeAnimation.start()
    }

    function toggle() {
        if (isOpen) {
            close()
        } else {
            open()
        }
    }

    function editPinnedApps() {
        // Show pinned apps editor
        console.log("Edit pinned apps")
    }

    function showPowerMenu() {
        // Show power menu (shutdown, restart, sleep, etc.)
        powerMenu.open()
    }

    // User data (will be provided by shell)
    property string userName: "User"
    property string userAvatarImage: ""
}
