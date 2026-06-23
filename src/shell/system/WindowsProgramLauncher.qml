import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * WindowsProgramLauncher - Windows 程序启动器
 * 用于在 FluentOS 中直接启动 Windows 程序
 */

Item {
    id: launcher

    // Program list model
    ListModel {
        id: programModel
    }

    // Loading state
    property bool isLoading: false
    property string errorMessage: ""

    // Search filter
    property string searchFilter: ""
    property var filteredPrograms: []

    // Component initialization
    Component.onCompleted: {
        loadWindowsPrograms()
    }

    /**
     * 加载 Windows 程序列表
     */
    function loadWindowsPrograms() {
        isLoading = true
        errorMessage = ""

        // Run Python script to get Windows programs
        var proc = process.start("/usr/bin/python3",
            ["/usr/share/fluentos/scripts/find_windows_programs.py"])

        proc.onReadyRead = function() {
            try {
                var data = JSON.parse(proc.readAll())
                updateProgramModel(data)
            } catch (e) {
                errorMessage = "Failed to parse program list"
            }
        }

        proc.onFinished = function(exitCode) {
            isLoading = false
            if (exitCode !== 0) {
                errorMessage = "Failed to load Windows programs"
            }
        }
    }

    /**
     * 更新程序模型
     */
    function updateProgramModel(programs) {
        programModel.clear()
        for (var i = 0; i < programs.length; i++) {
            var prog = programs[i]
            programModel.append({
                name: prog.name,
                path: prog.path,
                size: formatSize(prog.size),
                type: prog.type,
                icon: getProgramIcon(prog.name)
            })
        }
        filteredPrograms = programs
    }

    /**
     * 启动程序
     */
    function launchProgram(path) {
        if (!path) return

        // 使用 wine 或直接调用
        var proc = process.startDetached("/usr/bin/wine", [path])
        if (!proc) {
            // 如果 wine 不可用，尝试直接执行
            process.startDetached(path)
        }
    }

    /**
     * 获取程序图标（返回图标名称）
     */
    function getProgramIcon(name) {
        var nameLower = name.toLowerCase()

        // 根据程序名称返回对应的图标
        if (nameLower.includes("chrome") || nameLower.includes("google")) return "chrome"
        if (nameLower.includes("firefox") || nameLower.includes("mozilla")) return "firefox"
        if (nameLower.includes("office") || nameLower.includes("word") || nameLower.includes("excel")) return "office"
        if (nameLower.includes("photoshop") || nameLower.includes("adobe")) return "photoshop"
        if (nameLower.includes("qq") || nameLower.includes("tencent")) return "qq"
        if (nameLower.includes("wechat")) return "wechat"
        if (nameLower.includes("steam")) return "steam"
        if (nameLower.includes("vscode") || nameLower.includes("visual studio")) return "vscode"
        if (nameLower.includes("notepad")) return "notepad"
        if (nameLower.includes("explorer")) return "explorer"
        if (nameLower.includes("settings") || nameLower.includes("control")) return "settings"

        return "default"
    }

    /**
     * 格式化文件大小
     */
    function formatSize(bytes) {
        if (!bytes || bytes < 0) return ""
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1024 * 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + " MB"
        return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB"
    }

    /**
     * 搜索程序
     */
    function searchPrograms(query) {
        searchFilter = query
        if (!query || query.length < 1) {
            filteredPrograms = programModel
            return
        }

        var queryLower = query.toLowerCase()
        filteredPrograms = []

        for (var i = 0; i < programModel.count; i++) {
            var prog = programModel.get(i)
            if (prog.name.toLowerCase().indexOf(queryLower) !== -1) {
                filteredPrograms.push(prog)
            }
        }
    }

    /**
     * 按名称排序
     */
    function sortByName() {
        filteredPrograms.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })
    }

    /**
     * 按大小排序
     */
    function sortBySize() {
        filteredPrograms.sort(function(a, b) {
            return (b.size || 0) - (a.size || 0)
        })
    }

    /**
     * 刷新程序列表
     */
    function refresh() {
        loadWindowsPrograms()
    }
}

/**
 * WindowsProgramTile - Windows 程序磁贴组件
 */
Component {
    id: programTile

    Rectangle {
        id: tile
        width: 120
        height: 100
        radius: 8
        color: tileMouse.containsMouse ? "#E5E5E5" : "transparent"

        property bool isHovered: false

        Column {
            anchors.centerIn: parent
            spacing: 8

            // Program icon
            Image {
                id: iconImage
                width: 40
                height: 40
                source: iconUrl
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize: Qt.size(40, 40)
            }

            // Program name
            Text {
                text: name
                color: "#1F1F1F"
                font.pixelSize: 11
                font.family: "Segoe UI"
                elide: Text.ElideMiddle
                maximumLineCount: 2
                width: 100
                horizontalAlignment: Text.AlignHCenter
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true

            onEntered: tile.isHovered = true
            onExited: tile.isHovered = false

            onClicked: {
                launcher.launchProgram(path)
            }
        }

        // Tooltip
        ToolTip {
            text: path
            delay: 500
            visible: tile.isHovered
            parent: tile
        }
    }
}

/**
 * WindowsProgramListItem - Windows 程序列表项
 */
Component {
    id: programListItem

    Rectangle {
        id: item
        width: parent ? parent.width : 400
        height: 48
        color: itemMouse.containsMouse ? "#F0F0F0" : "transparent"
        radius: 4

        property bool isHovered: false

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            spacing: 12

            // Icon
            Image {
                width: 32
                height: 32
                source: iconUrl
                anchors.verticalCenter: parent.verticalCenter
                sourceSize: Qt.size(32, 32)
            }

            // Name and path
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: name
                    color: "#1F1F1F"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                Text {
                    text: path
                    color: "#888888"
                    font.pixelSize: 11
                    elide: Text.ElideLeft
                    width: 300
                }
            }

            // Size
            Text {
                text: size
                color: "#888888"
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: itemMouse
            anchors.fill: parent
            hoverEnabled: true

            onEntered: item.isHovered = true
            onExited: item.isHovered = false

            onClicked: {
                launcher.launchProgram(path)
            }

            onDoubleClicked: {
                launcher.launchProgram(path)
            }
        }
    }
}
