import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * WindowsDriveMount - Windows 分区挂载组件
 * 用于在文件管理器中显示和挂载 Windows 分区
 */

Item {
    id: mountManager

    // 挂载状态
    property var mountedDrives: []
    property var availableDrives: []
    property bool isLoading: false

    // 信号
    signal driveMounted(string mountPoint, string device)
    signal driveUnmounted(string mountPoint)
    signal mountError(string message)

    Component.onCompleted: {
        refreshDrives()
    }

    /**
     * 刷新可用驱动器列表
     */
    function refreshDrives() {
        isLoading = true

        var proc = process.start("/usr/bin/python3",
            ["/usr/share/fluentos/scripts/windows_drive_manager.py", "--list-drives"])

        proc.onReadyRead = function() {
            try {
                var data = JSON.parse(proc.readAll())
                availableDrives = data
                updateMountedStatus()
            } catch (e) {
                mountError("Failed to parse drive list")
            }
        }

        proc.onFinished = function(exitCode) {
            isLoading = false
        }
    }

    /**
     * 更新已挂载状态
     */
    function updateMountedStatus() {
        for (var i = 0; i < availableDrives.length; i++) {
            var drive = availableDrives[i]
            if (drive.mountpoint) {
                if (!isMounted(drive.device)) {
                    mountedDrives.append({
                        device: drive.device,
                        mountpoint: drive.mountpoint,
                        label: drive.label,
                        size: drive.size
                    })
                }
            }
        }
    }

    /**
     * 检查驱动器是否已挂载
     */
    function isMounted(device) {
        for (var i = 0; i < mountedDrives.length; i++) {
            if (mountedDrives[i].device === device) {
                return true
            }
        }
        return false
    }

    /**
     * 挂载驱动器
     */
    function mountDrive(device, label) {
        isLoading = true

        var proc = process.start("/usr/bin/python3",
            ["/usr/share/fluentos/scripts/windows_drive_manager.py", "--mount", device])

        proc.onReadyRead = function() {
            var result = proc.readAll().trim()
            if (result.startsWith("Mounted at:")) {
                var mountPoint = result.replace("Mounted at:", "").trim()
                mountedDrives.append({
                    device: device,
                    mountpoint: mountPoint,
                    label: label || "Windows"
                })
                driveMounted(mountPoint, device)
            } else if (result === "Mount failed") {
                mountError("Failed to mount " + device)
            }
        }

        proc.onFinished = function(exitCode) {
            isLoading = false
            if (exitCode !== 0) {
                mountError("Mount process failed with exit code " + exitCode)
            }
        }
    }

    /**
     * 卸载驱动器
     */
    function unmountDrive(mountPoint) {
        isLoading = true

        var proc = process.start("/usr/bin/python3",
            ["/usr/share/fluentos/scripts/windows_drive_manager.py", "--unmount", mountPoint])

        proc.onReadyRead = function() {
            var result = proc.readAll().trim()
            if (result === "Unmounted successfully") {
                for (var i = 0; i < mountedDrives.length; i++) {
                    if (mountedDrives[i].mountpoint === mountPoint) {
                        mountedDrives.remove(i)
                        break
                    }
                }
                driveUnmounted(mountPoint)
            } else if (result === "Unmount failed") {
                mountError("Failed to unmount " + mountPoint)
            }
        }

        proc.onFinished = function(exitCode) {
            isLoading = false
        }
    }

    /**
     * 挂载所有 Windows 分区
     */
    function mountAllDrives() {
        var proc = process.start("/usr/bin/python3",
            ["/usr/share/fluentos/scripts/windows_drive_manager.py", "--mount-all"])

        proc.onFinished = function(exitCode) {
            refreshDrives()
        }
    }

    /**
     * 获取驱动器图标
     */
    function getDriveIcon(drive) {
        var label = (drive.label || "").toLowerCase()
        if (label.includes("windows") || label.includes("系统")) return "windows"
        if (label.includes("data") || label.includes("数据")) return "database"
        if (label.includes("media") || label.includes("媒体")) return "media"
        if (label.includes("backup") || label.includes("备份")) return "backup"
        return "drive"
    }
}

/**
 * DriveListItem - 驱动器列表项
 */
Component {
    id: driveListItem

    Rectangle {
        id: driveItem
        width: parent ? parent.width : 300
        height: 56
        color: "transparent"
        radius: 4

        property bool isHovered: false
        property bool isMounted: model.mountpoint && model.mountpoint.length > 0

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // Drive icon
            Rectangle {
                width: 40
                height: 40
                radius: 8
                color: isMounted ? "#E3F2FD" : "#F5F5F5"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: isMounted ? "\uD83D\uDCBE" : "\uD83D\uDCC1"
                    font.pixelSize: 20
                    anchors.centerIn: parent
                }
            }

            // Drive info
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: model.label || "本地磁盘"
                    color: "#1F1F1F"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }

                Text {
                    text: model.size || ""
                    color: "#888888"
                    font.pixelSize: 12
                }

                Text {
                    text: model.device || ""
                    color: "#AAAAAA"
                    font.pixelSize: 11
                }
            }

            Item { Layout.fillWidth: true }

            // Mount/Unmount button
            Rectangle {
                width: 80
                height: 32
                radius: 4
                color: isMounted ? "#FFEBEE" : "#E8F5E9"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: isMounted ? "卸载" : "挂载"
                    color: isMounted ? "#D32F2F" : "#388E3C"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                    onClicked: {
                        if (isMounted) {
                            mountManager.unmountDrive(model.mountpoint)
                        } else {
                            mountManager.mountDrive(model.device, model.label)
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: driveItem.isHovered = true
            onExited: driveItem.isHovered = false
        }

        // Hover background
        Rectangle {
            anchors.fill: parent
            color: "#F0F0F0"
            radius: 4
            visible: driveItem.isHovered
        }
    }
}

/**
 * DriveTile - 驱动器磁贴
 */
Component {
    id: driveTile

    Rectangle {
        id: tile
        width: 160
        height: 120
        radius: 8
        color: tileMouse.containsMouse ? "#F5F5F5" : "#FAFAFA"
        border.width: 1
        border.color: "#E0E0E0"

        property bool isHovered: false
        property bool isMounted: model.mountpoint && model.mountpoint.length > 0

        Column {
            anchors.centerIn: parent
            spacing: 8

            // Drive icon
            Text {
                text: isMounted ? "\uD83D\uDCBE" : "\uD83D\uDCC1"
                font.pixelSize: 36
                anchors.horizontalCenter: parent.horizontalCenter
                color: isMounted ? "#1976D2" : "#757575"
            }

            // Drive label
            Text {
                text: model.label || "本地磁盘"
                color: "#1F1F1F"
                font.pixelSize: 13
                font.weight: Font.Medium
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideMiddle
                width: 140
                horizontalAlignment: Text.AlignHCenter
            }

            // Size
            Text {
                text: model.size || ""
                color: "#888888"
                font.pixelSize: 11
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Status
            Text {
                text: isMounted ? "已挂载" : "未挂载"
                color: isMounted ? "#388E3C" : "#F57C00"
                font.pixelSize: 11
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            onEntered: tile.isHovered = true
            onExited: tile.isHovered = false
            onClicked: {
                if (isMounted) {
                    // 打开文件管理器到挂载点
                    fileManager.navigateTo(model.mountpoint)
                } else {
                    mountManager.mountDrive(model.device, model.label)
                }
            }
        }
    }
}
