import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Item {
    id: systemTray

    property var notifications: []
    property bool showNetworkIcon: true
    property bool showVolumeIcon: true
    property bool showBatteryIcon: true
    property bool showClock: true
    property bool showActionCenter: true

    RowLayout {
        anchors.fill: parent
        spacing: 2

        // Network Icon
        TrayIcon {
            id: networkIcon
            iconSource: "qrc:/icons/network.svg"
            visible: showNetworkIcon
            tooltip: "网络"

            onClicked: quickSettings.open("network")
        }

        // Volume Icon
        TrayIcon {
            id: volumeIcon
            iconSource: "qrc:/icons/volume.svg"
            visible: showVolumeIcon
            tooltip: "音量"

            onClicked: quickSettings.open("volume")
        }

        // Battery Icon (laptops only)
        TrayIcon {
            id: batteryIcon
            iconSource: "qrc:/icons/battery.svg"
            visible: showBatteryIcon
            tooltip: "电池"

            onClicked: quickSettings.open("battery")
        }

        // Separator
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 16
            color: "#555555"
        }

        // Action Center / Notifications Button
        TrayIcon {
            id: actionCenterIcon
            iconSource: "qrc:/icons/notifications.svg"
            visible: showActionCenter
            tooltip: "通知中心"

            property int notificationCount: 0

            Rectangle {
                anchors.top: parent.right
                anchors.rightMargin: -4
                width: 16
                height: 16
                radius: 8
                color: "#E81123"
                visible: notificationCount > 0

                Text {
                    anchors.centerIn: parent
                    text: notificationCount > 9 ? "9+" : String(notificationCount)
                    color: "white"
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            onClicked: notificationCenter.toggle()
        }

        // Clock
        ClockDisplay {
            id: clockDisplay
            visible: showClock
            showDate: false // Can be enabled for full date display
        }

        // Show Desktop button (far right)
        Rectangle {
            id: showDesktopButton
            width: 6
            height: parent.height - 8
            radius: 2
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = "#3D3D3D"
                onExited: parent.color = "transparent"
                onClicked: {
                    // Minimize all windows to show desktop
                    TaskbarModel.showDesktop()
                }
            }
        }
    }

    // Quick Settings Panel (slides down from right)
    QuickSettings {
        id: quickSettings
    }

    // Notification Center Panel
    NotificationCenter {
        id: notificationCenter
    }
}
