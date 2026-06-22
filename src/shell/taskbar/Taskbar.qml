import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Fluento.Taskbar 1.0

Rectangle {
    id: taskbar

    // Windows 11 style dimensions
    property int taskbarHeight: 48
    property int iconSize: 24
    property int itemSpacing: 4

    // Colors - Windows 11 dark theme
    readonly color backgroundColor: root.effectEnabled ? "#2D2D2D" : "#1F1F1F"
    readonly color hoverColor: "#3D3D3D"
    readonly color activeColor: "#4D4D4D"
    readonly color accentColor: "#0078D4"

    height: taskbarHeight
    color: backgroundColor

    // Pin to bottom (Windows default behavior)
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    // Enable blur effect when available
    layer.enabled: root.effectEnabled
    layer.effect: AcrylicBackground {
        tintColor: backgroundColor
        tintOpacity: 0.95
    }

    RowLayout {
        id: taskbarRow
        anchors.fill: parent
        anchors.margins: 4
        spacing: itemSpacing

        // === START MENU BUTTON ===
        StartMenuButton {
            id: startButton
            width: 48
            height: 40
            onClicked: startMenu.toggle()
        }

        // === SEARCH BUTTON (Optional) ===
        SearchButton {
            id: searchButton
            width: 40
            height: 40
            visible: false // Hidden by default, can be enabled
        }

        // === TASKBAR ITEMS (Pinned Apps) ===
        ListView {
            id: pinnedAppsView
            Layout.preferredWidth: contentWidth
            height: 40
            orientation: Qt.LeftToRight
            layoutDirection: Qt.LeftToRight
            model: TaskbarModel.pinnedApps
            delegate: PinnedItem {
                appId: modelData.appId
                appName: modelData.name
                appIcon: modelData.icon
                appPath: modelData.path
            }
            clip: true
        }

        // === SEPARATOR ===
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 24
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            color: "#555555"
            visible: runningWindowsModel.count > 0 && pinnedAppsView.count > 0
        }

        // === RUNNING WINDOWS ===
        ListView {
            id: runningWindowsView
            Layout.preferredWidth: implicitWidth
            Layout.fillWidth: false
            height: 40
            orientation: Qt.LeftToRight
            layoutDirection: Qt.LeftToRight
            model: TaskbarModel.runningWindows
            delegate: WindowButton {
                windowId: modelData.windowId
                windowTitle: modelData.title
                windowIcon: modelData.icon
                isActive: modelData.isActive
            }
            clip: true

            // Add spacing after running windows
            Layout.rightMargin: 8
        }

        // === SPACER ===
        Item { Layout.fillWidth: true }

        // === SYSTEM TRAY AREA ===
        SystemTray {
            id: systemTray
            width: childrenRect.width
            height: 40
        }

        // === SHOW DESKTOP BUTTON ===
        ShowDesktopButton {
            id: showDesktopButton
            width: 40
            height: 40
        }
    }

    // Reference to start menu (will be provided by shell)
    property var startMenu: null

    // Load running windows on startup
    Component.onCompleted: {
        TaskbarModel.loadRunningWindows()
    }

    // Update running windows when window changes
    Connections {
        target: TaskbarModel
        onRunningWindowsChanged: {
            TaskbarModel.loadRunningWindows()
        }
    }
}
