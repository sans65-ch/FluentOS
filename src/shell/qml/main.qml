import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Dialogs 1.3

/**
 * FluentOS Shell - Main QML
 * 主 Shell 入口，管理任务栏、开始菜单、桌面等
 */

ApplicationWindow {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    visibility: isTestMode ? Window.Windowed : Window.FullScreen

    title: "FluentOS Shell"
    color: "#F3F3F3"

    // 桌面背景
    Rectangle {
        id: desktop
        anchors.fill: parent
        color: "#0078D4"

        // 壁纸（如果可用）
        Image {
            anchors.fill: parent
            source: "file:///usr/share/backgrounds/fluentos/default.jpg"
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready

            // 加载失败时使用纯色背景
            onStatusChanged: {
                if (status === Image.Error) {
                    desktop.color = "#0078D4"
                }
            }
        }

        // 桌面图标区域
        Grid {
            id: desktopIcons
            columns: 1
            spacing: 8
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16

            Repeater {
                model: desktopModel
                delegate: DesktopIcon {
                    name: model.name
                    icon: model.icon
                    path: model.path
                }
            }
        }
    }

    // 桌面快捷方式模型
    ListModel {
        id: desktopModel

        ListElement {
            name: "此电脑"
            icon: "computer"
            path: "computer:///"
        }

        ListElement {
            name: "回收站"
            icon: "trash"
            path: "trash:///"
        }

        ListElement {
            name: "用户文件"
            icon: "folder-home"
            path: "~"
        }

        ListElement {
            name: "Windows 程序"
            icon: "windows"
            path: "/mnt/windows/Program Files"
        }
    }

    // 任务栏
    Taskbar {
        id: taskbar
        width: parent.width
        height: 48
        anchors.bottom: parent.bottom
        visible: true
    }

    // 开始菜单
    StartMenu {
        id: startMenu
        visible: false
        width: 640
        height: 720
        anchors.bottom: taskbar.top
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 8

        onClosed: {
            startMenu.visible = false
        }
    }

    // 全局快捷键
    Shortcut {
        sequence: "Super"
        onActivated: {
            startMenu.visible = !startMenu.visible
            if (startMenu.visible) {
                startMenu.focusSearch()
            }
        }
    }

    Shortcut {
        sequence: "Super+E"
        onActivated: {
            fileManager.open()
        }
    }

    Shortcut {
        sequence: "Alt+Tab"
        onActivated: {
            // 切换窗口
            // TODO: 实现窗口切换
        }
    }

    Shortcut {
        sequence: "Ctrl+Alt+Del"
        onActivated: {
            // 打开任务管理器
            // TODO: 实现任务管理器
        }
    }

    // 文件管理器窗口
    FileManager {
        id: fileManager
        visible: false
        width: 960
        height: 640
    }

    // 控制面板窗口
    ControlPanel {
        id: controlPanel
        visible: false
        width: 900
        height: 650
    }

    // Windows 程序启动器
    WindowsProgramLauncher {
        id: windowsLauncher
        visible: false
    }

    // 退出确认对话框
    Dialog {
        id: exitDialog
        title: "退出 FluentOS Shell"
        text: "确定要退出桌面环境吗？"
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            Qt.quit()
        }
    }

    // 组件加载
    Component.onCompleted: {
        console.log("FluentOS Shell 已启动")
        console.log("版本: " + applicationVersion)

        // 加载 Windows 驱动器
        // windowsDriveManager.refreshDrives()
    }
}

/**
 * DesktopIcon - 桌面图标组件
 */
Component {
    id: desktopIconComponent

    Item {
        id: iconItem
        width: 72
        height: 96

        property string name: ""
        property string icon: ""
        property string path: ""

        Column {
            anchors.fill: parent
            spacing: 4

            // 图标
            Rectangle {
                width: 48
                height: 48
                radius: 4
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    anchors.fill: parent
                    source: "image://icon/" + icon
                    sourceSize: Qt.size(48, 48)

                    // 图标不存在时使用默认图标
                    onStatusChanged: {
                        if (status === Image.Error) {
                            source = "qrc:/icons/default-app.png"
                        }
                    }
                }
            }

            // 名称
            Text {
                text: name
                color: "white"
                font.pixelSize: 11
                font.family: "Segoe UI"
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                style: Text.Outline
                styleColor: "#40000000"
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // 打开路径
                if (path) {
                    // TODO: 打开文件管理器
                }
            }
            onDoubleClicked: {
                if (path) {
                    // TODO: 执行程序或打开文件夹
                }
            }
        }
    }
}
