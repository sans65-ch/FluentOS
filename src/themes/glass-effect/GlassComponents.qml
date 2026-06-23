import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * AcrylicBackground - 亚克力材质背景组件
 * Windows 10/11 风格的半透明模糊效果
 */
Rectangle {
    id: root

    // 效果属性
    property real tintOpacity: 0.0
    property color tintColor: "#0078D4"
    property real blurStrength: 0.0
    property bool enabled: true

    // 动画
    property int animationDuration: 200

    color: enabled ? "transparent" : rootColor

    // 基础颜色
    readonly property color rootColor: "#F3F3F3"

    // 内部内容
    Rectangle {
        id: tintLayer
        anchors.fill: parent
        color: root.tintColor
        opacity: root.tintOpacity * 0.3
        visible: root.tintOpacity > 0 && root.enabled

        Behavior on opacity {
            NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutQuad }
        }
    }

    // 模拟模糊效果 (实际效果需要 KWin shader 支持)
    Rectangle {
        id: blurEffect
        anchors.fill: parent
        visible: root.enabled && root.blurStrength > 0

        // 使用半透明覆盖模拟模糊
        color: "transparent"

        // 高斯模糊模拟 (简化版)
        layer.enabled: true
        layer.effect: GaussianBlur {
            radius: root.blurStrength * 8
            deviation: root.blurStrength * 4
            samples: Math.floor(root.blurStrength * 16)
        }
    }

    // 噪点纹理 (可选)
    Item {
        id: noiseOverlay
        anchors.fill: parent
        visible: false // 默认隐藏

        // 使用噪点纹理覆盖
    }
}

/**
 * MicaBackground - 云母材质背景组件
 * Windows 11 风格的主要视觉效果
 */
Rectangle {
    id: root

    // 效果属性
    property real baseOpacity: 0.85
    property color tintColor: "#0078D4"
    property real tintAmount: 0.0
    property bool enabled: true

    // 动画
    property int animationDuration: 200

    color: "transparent"

    // 云母材质使用分层效果
    Rectangle {
        id: baseLayer
        anchors.fill: parent
        color: enabled ? "#FFFFFF" : "#F3F3F3"
        opacity: enabled ? 0.85 : 1.0

        Behavior on opacity {
            NumberAnimation { duration: root.animationDuration }
        }
    }

    Rectangle {
        id: tintLayer
        anchors.fill: parent
        color: root.tintColor
        opacity: root.tintAmount * 0.2 * root.baseOpacity
        visible: root.tintAmount > 0 && root.enabled

        Behavior on opacity {
            NumberAnimation { duration: root.animationDuration }
        }
    }

    // 顶部渐变 (云母特征)
    Rectangle {
        id: topGradient
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 0.6
        visible: root.enabled

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: Qt.rgba(1, 1, 1, 0.08)
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(0, 0, 0, 0)
            }
        }
    }
}

/**
 * GlassBackground - 液态玻璃效果组件
 * 高级透明效果
 */
Rectangle {
    id: root

    // 效果属性
    property real strength: 0.0  // 0-1
    property real highlight: 0.0  // 0-1
    property color tintColor: "#0078D4"
    property real tintOpacity: 0.0
    property bool enabled: true

    // 动画
    property int animationDuration: 200

    // 基础颜色
    color: enabled ? "#20000000" : "#F3F3F3"

    // 边缘高光效果
    Rectangle {
        id: leftHighlight
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        visible: root.enabled && root.highlight > 0
        opacity: root.highlight * 0.3

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: "white" }
        }
    }

    // 染色层
    Rectangle {
        id: tintOverlay
        anchors.fill: parent
        color: root.tintColor
        opacity: root.tintOpacity * 0.25 * root.strength
        visible: root.tintOpacity > 0 && root.enabled

        Behavior on opacity {
            NumberAnimation { duration: root.animationDuration }
        }
    }

    // 边框
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1 * root.strength)
        radius: 8
        visible: root.enabled
    }
}

/**
 * EffectSettingsButton - 效果设置按钮
 * 用于在控制面板中切换效果
 */
Button {
    id: effectButton

    property string effectName: ""
    property bool isActive: false

    // 样式
    flat: true
    padding: 8

    contentItem: Column {
        spacing: 4
        anchors.horizontalCenter: parent.horizontalCenter

        // 效果图标
        Rectangle {
            width: 48
            height: 48
            radius: 8
            color: isActive ? "#0078D4" : "#E5E5E5"
            anchors.horizontalCenter: parent.horizontalCenter

            // 效果预览
            Rectangle {
                anchors.centerIn: parent
                width: 32
                height: 32
                radius: 4
                color: isActive ? "white" : "#CCCCCC"
            }
        }

        // 效果名称
        Text {
            text: effectName
            color: isActive ? "#0078D4" : "#1F1F1F"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // 点击切换
    onClicked: {
        isActive = !isActive
    }
}
