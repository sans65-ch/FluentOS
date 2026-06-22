import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Dialogs 1.3

ApplicationWindow {
    id: fileManager

    // Window properties
    title: currentPath
    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600

    // Theme colors
    readonly color accentColor: "#0078D4"
    readonly color backgroundColor: "#F3F3F3"
    readonly color surfaceColor: "#FFFFFF"
    readonly color hoverColor: "#E5E5E5"
    readonly color selectedColor: "#CCE4F7"
    readonly color textColor: "#1F1F1F"
    readonly color secondaryTextColor: "#666666"

    // Current path
    property string currentPath: "file:///home/" + userName
    property var currentItems: []
    property var selectedItems: []
    property int viewMode: 0 // 0=Details, 1=Tiles, 2=Content

    // Sort settings
    property string sortBy: "name" // name, date, size, type
    property bool sortDescending: false

    // Navigation
    property var history: []
    property int historyIndex: -1

    // State
    property string clipboardPath: ""
    property bool isCut: false

    header: TitleBar {
        id: titleBar

        // Navigation buttons
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 8
            spacing: 4

            // Back button
            Rectangle {
                id: backButton
                width: 32
                height: 32
                radius: 4
                color: "transparent"

                Text {
                    text: "\u2190"
                    font.pixelSize: 16
                    color: canGoBack ? textColor : "#CCCCCC"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: canGoBack
                    hoverEnabled: true
                    onEntered: if (canGoBack) parent.color = hoverColor
                    onExited: parent.color = "transparent"
                    onClicked: goBack()
                }
            }

            // Forward button
            Rectangle {
                id: forwardButton
                width: 32
                height: 32
                radius: 4
                color: "transparent"

                Text {
                    text: "\u2192"
                    font.pixelSize: 16
                    color: canGoForward ? textColor : "#CCCCCC"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: canGoForward
                    hoverEnabled: true
                    onEntered: if (canGoForward) parent.color = hoverColor
                    onExited: parent.color = "transparent"
                    onClicked: goForward()
                }
            }

            // Up button
            Rectangle {
                id: upButton
                width: 32
                height: 32
                radius: 4
                color: "transparent"

                Text {
                    text: "\u2191"
                    font.pixelSize: 16
                    color: canGoUp ? textColor : "#CCCCCC"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: canGoUp
                    hoverEnabled: true
                    onEntered: if (canGoUp) parent.color = hoverColor
                    onExited: parent.color = "transparent"
                    onClicked: goUp()
                }
            }
        }

        // Address bar
        Rectangle {
            id: addressBar
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: 32
            radius: 4
            color: surfaceColor
            border.width: 1
            border.color: "#E0E0E0"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                Text {
                    text: "\uD83D\uDCC1"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: pathInput
                    text: currentPath.replace("file://", "")
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    font.family: "Segoe UI"
                    color: textColor
                    verticalAlignment: Text.AlignVCenter

                    onAccepted: {
                        navigateTo(text)
                    }
                }
            }
        }

        // View options
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            spacing: 4

            // View mode buttons
            Repeater {
                model: [
                    { icon: "\u2630", mode: 0 },  // Details
                    { icon: "\u25A6", mode: 1 },  // Tiles
                    { icon: "\u2630", mode: 2 }   // Content
                ]

                Rectangle {
                    width: 32
                    height: 32
                    radius: 4
                    color: viewMode === modelData.mode ? hoverColor : "transparent"

                    Text {
                        text: modelData.icon
                        font.pixelSize: 14
                        color: textColor
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: if (viewMode !== modelData.mode) parent.color = hoverColor
                        onExited: parent.color = viewMode === modelData.mode ? hoverColor : "transparent"
                        onClicked: viewMode = modelData.mode
                    }
                }
            }
        }
    }

    // Main content
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Navigation pane (left sidebar)
        NavigationPane {
            id: navPane
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            currentPath: fileManager.currentPath

            onNavigate: {
                fileManager.navigateTo(path)
            }
        }

        // File list area
        Rectangle {
            id: fileListArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: surfaceColor

            // Breadcrumb bar
            BreadcrumbBar {
                id: breadcrumbBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 32
                currentPath: fileManager.currentPath

                onNavigate: {
                    fileManager.navigateTo(path)
                }
            }

            // Column headers (Details view)
            Rectangle {
                id: columnHeaders
                anchors.top: breadcrumbBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 28
                color: backgroundColor
                visible: viewMode === 0

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 48

                    // Name column
                    HeaderCell {
                        text: "名称"
                        width: 300
                        sortBy: "name"
                        isSorted: sortBy === "name"
                        ascending: !sortDescending
                    }

                    // Size column
                    HeaderCell {
                        text: "大小"
                        width: 100
                        sortBy: "size"
                        isSorted: sortBy === "size"
                        ascending: !sortDescending
                    }

                    // Date modified column
                    HeaderCell {
                        text: "修改日期"
                        width: 180
                        sortBy: "date"
                        isSorted: sortBy === "date"
                        ascending: !sortDescending
                    }

                    // Type column
                    HeaderCell {
                        text: "类型"
                        width: 150
                        sortBy: "type"
                        isSorted: sortBy === "type"
                        ascending: !sortDescending
                    }
                }
            }

            // File list
            FileListView {
                id: fileListView
                anchors.top: viewMode === 0 ? columnHeaders.bottom : breadcrumbBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: statusBar.top
                currentPath: fileManager.currentPath
                viewMode: fileManager.viewMode
                sortBy: fileManager.sortBy
                sortDescending: fileManager.sortDescending

                onItemClicked: {
                    selectedItems = [itemPath]
                }

                onItemDoubleClicked: {
                    if (isDirectory) {
                        navigateTo(itemPath)
                    } else {
                        openFile(itemPath)
                    }
                }

                onSelectionChanged: {
                    selectedItems = selectedPaths
                }
            }

            // Status bar
            Rectangle {
                id: statusBar
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 24
                color: backgroundColor

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    Text {
                        text: selectedItems.length > 0
                            ? selectedItems.length + " 个项目已选中"
                            : currentItems.length + " 个项目"
                        color: secondaryTextColor
                        font.pixelSize: 12
                    }

                    Text {
                        text: calculateSelectedSize()
                        color: secondaryTextColor
                        font.pixelSize: 12
                        visible: selectedItems.length > 0
                    }
                }
            }
        }

        // Details pane (right sidebar)
        DetailsPane {
            id: detailsPane
            Layout.preferredWidth: selectedItems.length > 0 ? 280 : 0
            Layout.fillHeight: true
            visible: selectedItems.length > 0
            selectedItems: fileManager.selectedItems

            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 150 }
            }
        }
    }

    // Context menu
    Menu {
        id: contextMenu

        MenuItem {
            text: "打开"
            onTriggered: {
                if (selectedItems.length === 1) {
                    var item = selectedItems[0]
                    if (itemIsDirectory(item)) {
                        navigateTo(item)
                    } else {
                        openFile(item)
                    }
                }
            }
        }

        MenuItem {
            text: "在新窗口中打开"
            onTriggered: openInNewWindow()
        }

        MenuSeparator {}

        MenuItem {
            text: "剪切"
            onTriggered: cutSelection()
        }

        MenuItem {
            text: "复制"
            onTriggered: copySelection()
        }

        MenuItem {
            text: "粘贴"
            onTriggered: paste()
        }

        MenuSeparator {}

        MenuItem {
            text: "重命名"
            onTriggered: renameSelection()
        }

        MenuItem {
            text: "删除"
            onTriggered: deleteSelection()
        }

        MenuSeparator {}

        MenuItem {
            text: "属性"
            onTriggered: showProperties()
        }
    }

    // Keyboard shortcuts
    Keys.onPressed: {
        if (event.key === Qt.Key_Backspace) {
            goUp()
        } else if (event.modifiers & Qt.ControlModifier) {
            if (event.key === Qt.Key_C) copySelection()
            else if (event.key === Qt.Key_X) cutSelection()
            else if (event.key === Qt.Key_V) paste()
            else if (event.key === Qt.Key_Z) undo()
            else if (event.key === Qt.Key_A) selectAll()
        }
    }

    // Navigation functions
    function navigateTo(path) {
        // Add to history
        if (historyIndex < history.length - 1) {
            history = history.slice(0, historyIndex + 1)
        }
        history.push(currentPath)
        historyIndex = history.length - 1

        currentPath = path
        loadDirectory(path)
    }

    function loadDirectory(path) {
        currentItems = FileManager.listDirectory(path)
        selectedItems = []
    }

    function goBack() {
        if (historyIndex > 0) {
            historyIndex--
            currentPath = history[historyIndex]
            loadDirectory(currentPath)
        }
    }

    function goForward() {
        if (historyIndex < history.length - 1) {
            historyIndex++
            currentPath = history[historyIndex]
            loadDirectory(currentPath)
        }
    }

    function goUp() {
        var parentPath = currentPath.substring(0, currentPath.lastIndexOf("/"))
        if (parentPath) navigateTo(parentPath)
    }

    property bool canGoBack: historyIndex > 0
    property bool canGoForward: historyIndex < history.length - 1
    property bool canGoUp: currentPath !== "/"

    // File operations
    function openFile(path) {
        FileManager.openFile(path)
    }

    function openInNewWindow() {
        for (var i = 0; i < selectedItems.length; i++) {
            FileManager.openInNewWindow(selectedItems[i])
        }
    }

    function cutSelection() {
        clipboardPath = selectedItems.join("\n")
        isCut = true
    }

    function copySelection() {
        clipboardPath = selectedItems.join("\n")
        isCut = false
    }

    function paste() {
        if (isCut) {
            FileManager.moveFiles(clipboardPath.split("\n"), currentPath)
            isCut = false
        } else {
            FileManager.copyFiles(clipboardPath.split("\n"), currentPath)
        }
        clipboardPath = ""
        loadDirectory(currentPath)
    }

    function renameSelection() {
        if (selectedItems.length === 1) {
            showRenameDialog(selectedItems[0])
        }
    }

    function deleteSelection() {
        FileManager.deleteFiles(selectedItems)
        loadDirectory(currentPath)
    }

    function selectAll() {
        selectedItems = currentItems.map(function(item) { return item.path })
    }

    function undo() {
        FileManager.undo()
        loadDirectory(currentPath)
    }

    function calculateSelectedSize() {
        var total = 0
        for (var i = 0; i < selectedItems.length; i++) {
            var item = getItemInfo(selectedItems[i])
            if (item) total += item.size
        }
        return formatSize(total)
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        else if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        else if (bytes < 1024 * 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + " MB"
        else return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB"
    }

    function getItemInfo(path) {
        for (var i = 0; i < currentItems.length; i++) {
            if (currentItems[i].path === path) return currentItems[i]
        }
        return null
    }

    function itemIsDirectory(path) {
        var item = getItemInfo(path)
        return item ? item.isDirectory : false
    }

    // User data
    property string userName: "user"
}
