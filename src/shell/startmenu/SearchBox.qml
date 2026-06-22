import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: searchBox

    property string text: ""
    property alias placeholderText: placeholder.text

    height: 36
    radius: 4
    color: "#FFFFFF"
    border.width: 1
    border.color: "#E0E0E0"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        // Search icon
        Text {
            text: "\uD83D\uDD0D"
            font.pixelSize: 14
            color: "#888888"
            Layout.alignment: Qt.AlignVCenter
        }

        // Text input
        TextInput {
            id: textInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
            font.family: "Segoe UI"
            color: textColor
            selectByMouse: true
            activeFocusOnPress: true

            // Placeholder
            Text {
                id: placeholder
                text: "在此处键入以搜索"
                color: "#888888"
                font.pixelSize: 14
                font.family: "Segoe UI"
                verticalAlignment: Text.AlignVCenter
                visible: textInput.text === ""
            }

            onTextChanged: {
                parent.parent.parent.text = textInput.text
                searchBox.textChanged(textInput.text)
            }
        }

        // Clear button (when text present)
        Rectangle {
            id: clearButton
            width: 20
            height: 20
            radius: 10
            color: "#CCCCCC"
            visible: textInput.text !== ""
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "\u2715"
                color: "white"
                font.pixelSize: 10
                font.bold: true
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = "#AAAAAA"
                onExited: parent.color = "#CCCCCC"
                onClicked: {
                    textInput.text = ""
                }
            }

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }
    }

    // Focus state
    states: State {
        name: "focused"
        when: textInput.activeFocus
        PropertyChanges {
            target: searchBox
            border.color: accentColor
        }
    }

    transitions: Transition {
        PropertyAnimation {
            property: "border.color"
            duration: 150
        }
    }

    signal textChanged(string query)

    readonly color textColor: "#1F1F1F"
    readonly color accentColor: "#0078D4"
}
