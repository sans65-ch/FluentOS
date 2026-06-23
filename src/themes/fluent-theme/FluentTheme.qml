/*
 * FluentOS Fluent Design Theme
 * 基于 Windows 11 Fluent Design System
 *
 * 特性:
 * - 轻量级动画
 * - 亚克力/云母材质效果
 * - 圆角设计
 * - 阴影和深度
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

/* ========================================================================
 * Fluent 颜色系统
 * ======================================================================== */

QtObject {
    // Windows 11 Fluent 颜色
    property color accent: "#0078D4"
    property color accentLight: "#60CDFF"
    property color accentDark: "#004E8C"

    // 浅色主题
    readonly property color lightBackground: "#F3F3F3"
    readonly property color lightSurface: "#FFFFFF"
    readonly property color lightSurfaceVariant: "#F9F9F9"
    readonly property color lightBorder: "#E0E0E0"
    readonly property color lightText: "#1F1F1F"
    readonly property color lightTextSecondary: "#666666"
    readonly property color lightTextTertiary: "#999999"

    // 深色主题
    readonly property color darkBackground: "#1F1F1F"
    readonly property color darkSurface: "#2D2D2D"
    readonly property color darkSurfaceVariant: "#383838"
    readonly property color darkBorder: "#404040"
    readonly property color darkText: "#FFFFFF"
    readonly property color darkTextSecondary: "#AAAAAA"
    readonly property color darkTextTertiary: "#777777"

    // 毛玻璃颜色
    readonly property color blurLight: "#80FFFFFF"
    readonly property color blurDark: "#80000000"

    // 系统颜色
    readonly property color success: "#107C10"
    readonly property color warning: "#FFB900"
    readonly property color error: "#E81123"
    readonly property color info: "#0078D4"

    // 阴影
    readonly property color shadowLight: "#10000000"
    readonly property color shadowMedium: "#20000000"
    readonly property color shadowDark: "#30000000"
}

/* ========================================================================
 * Fluent 按钮样式
 * ======================================================================== */

T.Button {
    id: control

    // 圆角
    property int radius: 4

    // 动画
    property int animationDuration: 150

    // 默认状态
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    // 背景
    background: Rectangle {
        id: bg
        implicitWidth: 94
        implicitHeight: 32
        radius: control.radius
        color: control.enabled
            ? (control.down ? control.pressedColor
                          : (control.hovered ? control.hoverColor : control.normalColor))
            : control.disabledColor

        // 边框
        border.width: control.outline ? 1 : 0
        border.color: control.outline ? (control.down ? control.pressedColor : control.borderColor) : "transparent"

        // 阴影 (可选)
        property bool showShadow: true
        layer.enabled: showShadow && !control.flat
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 4
            color: FluentTheme.shadowLight
            transparentBorder: true
        }

        // 状态颜色
        property color normalColor: control.flat ? "transparent" : FluentTheme.lightSurface
        property color hoverColor: FluentTheme.lightSurfaceVariant
        property color pressedColor: FluentTheme.lightBorder
        property color disabledColor: FluentTheme.lightBorder
        property color borderColor: FluentTheme.accent
    }

    // 内容
    contentItem: Text {
        text: control.text
        font: control.font
        color: control.enabled
            ? (control.flat && control.hovered ? FluentTheme.accent : FluentTheme.lightText)
            : FluentTheme.lightTextTertiary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // 主题属性
    property bool outline: false
}

/* ========================================================================
 * Fluent 文本框样式
 * ======================================================================== */

T.TextField {
    id: control

    property int radius: 4
    property int animationDuration: 150

    implicitWidth: Math.max(contentWidth + leftPadding + rightPadding, 120)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, 32)

    // 背景
    background: Rectangle {
        id: bg
        implicitWidth: 150
        implicitHeight: 32
        radius: control.radius
        color: FluentTheme.lightSurface
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? FluentTheme.accent : FluentTheme.lightBorder

        // 过渡动画
        Behavior on border.color {
            NumberAnimation { duration: control.animationDuration }
        }
    }

    // 占位符
    placeholderTextColor: FluentTheme.lightTextTertiary

    // 文本颜色
    color: FluentTheme.lightText
    selectionColor: FluentTheme.accent
    selectedTextColor: "white"
}

/* ========================================================================
 * Fluent 滑块样式
 * ======================================================================== */

T.Slider {
    id: control

    property int animationDuration: 150

    // 轨道
    background: Rectangle {
        id: trackBg
        x: control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        width: control.availableWidth
        height: 4
        radius: 2
        color: FluentTheme.lightBorder

        // 进度
        Rectangle {
            id: trackFill
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: FluentTheme.accent

            Behavior on width {
                NumberAnimation { duration: control.animationDuration }
            }
        }
    }

    // 滑块手柄
    handle: Rectangle {
        id: handleRect
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 18
        height: 18
        radius: 9
        color: "white"
        border.width: 2
        border.color: FluentTheme.accent

        // 阴影
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 4
            color: FluentTheme.shadowMedium
        }

        Behavior on x {
            NumberAnimation { duration: control.animationDuration }
        }
    }

    // 按下效果
    state: control.pressed ? "pressed" : (control.hovered ? "hovered" : "")

    states: [
        State {
            name: "hovered"
            PropertyChanges {
                target: handleRect
                border.width: 3
            }
        },
        State {
            name: "pressed"
            PropertyChanges {
                target: handleRect
                border.width: 4
                scale: 1.1
            }
        }
    ]

    transitions: Transition {
        NumberAnimation { properties: "border.width,scale"; duration: 100 }
    }
}

/* ========================================================================
 * Fluent 开关样式
 * ======================================================================== */

T.Switch {
    id: control

    property int animationDuration: 150

    // 轨道
    background: Rectangle {
        id: track
        implicitWidth: 44
        implicitHeight: 22
        radius: 11
        color: control.checked ? FluentTheme.accent : FluentTheme.lightBorder

        Behavior on color {
            NumberAnimation { duration: control.animationDuration }
        }
    }

    // 手柄
    handle: Rectangle {
        id: handle
        x: control.leftPadding + (control.visualPosition * (parent.width - width))
        y: control.topPadding + (parent.height - height) / 2
        width: 16
        height: 16
        radius: 8
        color: "white"

        Behavior on x {
            NumberAnimation { duration: control.animationDuration }
        }

        // 阴影
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 3
            color: FluentTheme.shadowLight
        }
    }
}

/* ========================================================================
 * Fluent 复选框样式
 * ======================================================================== */

T.CheckBox {
    id: control

    property int animationDuration: 150

    indicator: Rectangle {
        id: indicator
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: 4
        color: control.checked ? FluentTheme.accent
                    : (control.down ? FluentTheme.lightBorder : FluentTheme.lightSurface)
        border.width: control.checked ? 0 : 1
        border.color: control.checked ? FluentTheme.accent : FluentTheme.lightBorder

        // 勾选图标
        Text {
            text: "\u2713"
            color: "white"
            font.pixelSize: 14
            font.bold: true
            visible: control.checked
            anchors.centerIn: parent
        }

        Behavior on color {
            NumberAnimation { duration: control.animationDuration }
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: FluentTheme.lightText
        leftPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter
    }
}

/* ========================================================================
 * Fluent 菜单样式
 * ======================================================================== */

T.Menu {
    id: menu

    property int animationDuration: 150

    // 背景
    background: Rectangle {
        id: menuBg
        color: FluentTheme.lightSurface
        radius: 8
        border.width: 1
        border.color: FluentTheme.lightBorder

        // 阴影
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 8
            color: FluentTheme.shadowMedium
        }
    }

    // 菜单项
    delegate: T.MenuItem {
        id: menuItem

        implicitWidth: 180
        implicitHeight: 36

        // 背景
        Rectangle {
            id: itemBg
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            radius: 4
            color: menuItem.highlighted ? FluentTheme.lightSurfaceVariant : "transparent"

            Behavior on color {
                NumberAnimation { duration: menu.animationDuration }
            }
        }

        // 指示器
        indicator: Rectangle {
            width: 4
            height: 16
            radius: 2
            color: FluentTheme.accent
            visible: menuItem.checkable && menuItem.checked
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
        }

        // 图标
        icon {
            color: FluentTheme.lightText
            width: 16
            height: 16
        }

        // 文本
        contentItem: Text {
            text: menuItem.text
            font: menuItem.font
            color: FluentTheme.lightText
            verticalAlignment: Text.AlignVCenter
            leftPadding: menuItem.indicator.width + menuItem.spacing
        }

        // 箭头
        arrow: Text {
            text: "\u203A"
            color: FluentTheme.lightTextSecondary
            font.pixelSize: 14
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8
        }
    }

    // 分隔符
    separator: Rectangle {
        height: 1
        color: FluentTheme.lightBorder
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8
        anchors.rightMargin: 8
    }
}
