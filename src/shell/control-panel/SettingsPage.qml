import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Flickable {
    id: settingsPage

    contentWidth: parent ? parent.width : 0
    contentHeight: contentColumn.height + 32
    clip: true

    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        spacing: 24

        // === DISPLAY SETTINGS PAGE ===
        Loader {
            active: currentPage === "display"
            sourceComponent: displaySettingsComponent
        }

        Component {
            id: displaySettingsComponent

            Column {
                spacing: 24

                // Brightness slider (laptops)
                SettingsSection {
                    title: "亮度和颜色"

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\u2600"
                                font.pixelSize: 24
                                color: "#666666"
                            }

                            Column {
                                spacing: 4

                                Text {
                                    text: "亮度"
                                    color: textColor
                                    font.pixelSize: 13
                                }

                                Slider {
                                    id: brightnessSlider
                                    width: 300
                                    from: 0
                                    to: 100
                                    value: 70
                                    onMoved: displaySettings.setBrightness(value / 100)
                                }
                            }

                            Text {
                                text: Math.round(brightnessSlider.value) + "%"
                                color: textColor
                                font.pixelSize: 13
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    SettingsItem {
                        Switch {
                            id: nightLightSwitch
                            text: "夜间模式"
                            checked: false
                            onToggled: displaySettings.setNightLight(checked)
                        }
                    }
                }

                // Display resolution
                SettingsSection {
                    title: "显示"

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\uD83D\uDDA5"
                                font.pixelSize: 24
                                color: "#666666"
                            }

                            Column {
                                spacing: 4

                                Text {
                                    text: "分辨率"
                                    color: textColor
                                    font.pixelSize: 13
                                }

                                ComboBox {
                                    id: resolutionCombo
                                    model: displaySettings.availableResolutions
                                    currentIndex: displaySettings.currentResolution
                                    onCurrentIndexChanged: {
                                        displaySettings.setResolution(currentIndex)
                                    }
                                }
                            }
                        }
                    }

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\uD83D\uDD5D"
                                font.pixelSize: 24
                                color: "#666666"
                            }

                            Column {
                                spacing: 4

                                Text {
                                    text: "缩放"
                                    color: textColor
                                    font.pixelSize: 13
                                }

                                ComboBox {
                                    id: scaleCombo
                                    model: ["100%", "125%", "150%", "175%", "200%"]
                                    currentIndex: 0
                                    onCurrentIndexChanged: {
                                        displaySettings.setScale(currentIndex)
                                    }
                                }
                            }
                        }
                    }

                    SettingsItem {
                        Switch {
                            id: hdrSwitch
                            text: "HDR"
                            checked: false
                            onToggled: displaySettings.setHDR(checked)
                        }
                    }
                }

                // Multiple displays
                SettingsSection {
                    title: "多显示器"

                    SettingsItem {
                        Column {
                            spacing: 8

                            Text {
                                text: "选择显示器"
                                color: textColor
                                font.pixelSize: 13
                            }

                            Repeater {
                                model: displaySettings.connectedMonitors

                                Row {
                                    spacing: 12

                                    RadioButton {
                                        checked: modelData.isPrimary
                                        onToggled: if (checked) displaySettings.setPrimaryMonitor(index)
                                    }

                                    Text {
                                        text: modelData.name + " (" + modelData.resolution + ")"
                                        color: textColor
                                        font.pixelSize: 13
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // === SOUND SETTINGS PAGE ===
        Loader {
            active: currentPage === "sound"
            sourceComponent: soundSettingsComponent
        }

        Component {
            id: soundSettingsComponent

            Column {
                spacing: 24

                SettingsSection {
                    title: "输出"

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\uD83C\uDFA7"
                                font.pixelSize: 24
                                color: "#666666"
                            }

                            Column {
                                spacing: 4

                                Text {
                                    text: "选择输出设备"
                                    color: textColor
                                    font.pixelSize: 13
                                }

                                ComboBox {
                                    id: outputCombo
                                    model: soundSettings.outputDevices
                                    currentIndex: soundSettings.currentOutput
                                }
                            }
                        }
                    }

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\uD83D\uDD08"
                                font.pixelSize: 20
                                color: "#666666"
                            }

                            Slider {
                                id: volumeSlider
                                width: 300
                                from: 0
                                to: 100
                                value: soundSettings.outputVolume
                                onMoved: soundSettings.setOutputVolume(value)
                            }

                            Text {
                                text: Math.round(volumeSlider.value) + "%"
                                color: textColor
                                font.pixelSize: 13
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    SettingsItem {
                        Switch {
                            id: muteSwitch
                            text: "静音"
                            checked: soundSettings.isMuted
                            onToggled: soundSettings.setMuted(checked)
                        }
                    }
                }

                SettingsSection {
                    title: "输入"

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\uD83C\uDF99"
                                font.pixelSize: 24
                                color: "#666666"
                            }

                            Column {
                                spacing: 4

                                Text {
                                    text: "选择输入设备"
                                    color: textColor
                                    font.pixelSize: 13
                                }

                                ComboBox {
                                    id: inputCombo
                                    model: soundSettings.inputDevices
                                    currentIndex: soundSettings.currentInput
                                }
                            }
                        }
                    }

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\uD83D\uDD0A"
                                font.pixelSize: 20
                                color: "#666666"
                            }

                            Slider {
                                id: inputVolumeSlider
                                width: 300
                                from: 0
                                to: 100
                                value: soundSettings.inputVolume
                                onMoved: soundSettings.setInputVolume(value)
                            }
                        }
                    }
                }
            }
        }

        // === THEME SETTINGS PAGE ===
        Loader {
            active: currentPage === "themes"
            sourceComponent: themeSettingsComponent
        }

        Component {
            id: themeSettingsComponent

            Column {
                spacing: 24

                SettingsSection {
                    title: "主题"

                    SettingsItem {
                        Row {
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "\u2728"
                                font.pixelSize: 24
                                color: "#666666"
                            }

                            Column {
                                spacing: 8

                                Text {
                                    text: "选择主题"
                                    color: textColor
                                    font.pixelSize: 13
                                }

                                Row {
                                    spacing: 12

                                    // Light theme option
                                    Rectangle {
                                        width: 100
                                        height: 70
                                        radius: 8
                                        border.width: themeSettings.currentTheme === "light" ? 2 : 1
                                        border.color: themeSettings.currentTheme === "light" ? accentColor : "#E0E0E0"
                                        color: "#FFFFFF"

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Rectangle {
                                                width: 40
                                                height: 20
                                                color: "#F0F0F0"
                                                radius: 2
                                            }

                                            Text {
                                                text: "浅色"
                                                color: textColor
                                                font.pixelSize: 11
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: themeSettings.setTheme("light")
                                        }
                                    }

                                    // Dark theme option
                                    Rectangle {
                                        width: 100
                                        height: 70
                                        radius: 8
                                        border.width: themeSettings.currentTheme === "dark" ? 2 : 1
                                        border.color: themeSettings.currentTheme === "dark" ? accentColor : "#E0E0E0"
                                        color: "#1F1F1F"

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Rectangle {
                                                width: 40
                                                height: 20
                                                color: "#2D2D2D"
                                                radius: 2
                                            }

                                            Text {
                                                text: "深色"
                                                color: "#FFFFFF"
                                                font.pixelSize: 11
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: themeSettings.setTheme("dark")
                                        }
                                    }

                                    // Custom theme option
                                    Rectangle {
                                        width: 100
                                        height: 70
                                        radius: 8
                                        border.width: themeSettings.currentTheme === "custom" ? 2 : 1
                                        border.color: themeSettings.currentTheme === "custom" ? accentColor : "#E0E0E0"
                                        gradient: Gradient {
                                            GradientStop { color: "#667eea"; position: 0 }
                                            GradientStop { color: "#764ba2"; position: 1 }
                                        }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: "\u2728"
                                                font.pixelSize: 20
                                                color: "white"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: "自定义"
                                                color: "white"
                                                font.pixelSize: 11
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: themeSettings.setTheme("custom")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                SettingsSection {
                    title: "效果"

                    SettingsItem {
                        Switch {
                            id: transparencySwitch
                            text: "透明效果"
                            checked: themeSettings.transparencyEnabled
                            onToggled: themeSettings.setTransparency(checked)
                        }
                    }

                    SettingsItem {
                        Switch {
                            id: animationSwitch
                            text: "动画效果"
                            checked: themeSettings.animationEnabled
                            onToggled: {
                                if (!checked) {
                                    // Show warning dialog
                                    animationWarningDialog.open()
                                } else {
                                    themeSettings.setAnimation(checked)
                                }
                            }
                        }

                        MessageDialog {
                            id: animationWarningDialog
                            title: "动画效果警告"
                            text: "启用动画效果可能会增加CPU和GPU负担。在低配置电脑上可能导致卡顿。"
                            standardButtons: StandardButton.Ok | StandardButton.Cancel
                            onAccepted: themeSettings.setAnimation(true)
                            onRejected: animationSwitch.checked = false
                        }
                    }
                }
            }
        }
    }

    // Placeholder
    placeholder: []

    readonly color textColor: "#1F1F1F"
    readonly color secondaryTextColor: "#666666"
    readonly color accentColor: "#0078D4"
}

// Settings section component
Column {
    id: settingsSection

    property string title: ""

    spacing: 8

    Text {
        text: title
        color: "#666666"
        font.pixelSize: 12
        font.weight: Font.Medium
    }

    Rectangle {
        width: parent.width
        height: 1
        color: "#E0E0E0"
    }
}

// Settings item component
Rectangle {
    id: settingsItem

    width: parent ? parent.width : 600
    height: 48
    color: "transparent"

    // Subclasses should override this
}
