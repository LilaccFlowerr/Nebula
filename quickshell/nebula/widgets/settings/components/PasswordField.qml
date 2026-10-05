import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

ColumnLayout {
    id: root

    property bool busy: false
    property string error: ""

    signal submitted(string password)

    function focusField() {
        input.text = "";
        input.forceActiveFocus();
    }

    spacing: Theme.spacing.xs

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: Theme.button.size
            radius: height / 2
            color: Colors.surfaceContainerHighest
            border.width: input.activeFocus ? 2 : 1
            border.color: input.activeFocus ? Colors.primary : Colors.outlineVariant

            TextInput {
                id: input
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.lg
                anchors.rightMargin: Theme.spacing.lg
                verticalAlignment: TextInput.AlignVCenter
                echoMode: reveal.checked ? TextInput.Normal : TextInput.Password
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Colors.textOnSurface
                selectionColor: Colors.primary
                selectedTextColor: Colors.textOnPrimary
                onAccepted: if (text !== "") root.submitted(text)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text === ""
                    text: "Password"
                    font: input.font
                    color: Colors.textOnSurfaceVariant
                }
            }
        }

        IconButton {
            id: reveal
            property bool checked: false
            icon: checked ? "visibility_off" : "visibility"
            onClicked: checked = !checked
        }

        Item {
            implicitWidth: Theme.button.size
            implicitHeight: Theme.button.size

            IconButton {
                anchors.centerIn: parent
                visible: !root.busy
                icon: "arrow_forward"
                onClicked: if (input.text !== "") root.submitted(input.text)
            }

            LoadingIndicator {
                anchors.fill: parent
                running: root.busy
            }
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spacing.lg
        visible: root.error !== ""
        text: root.error
        wrapMode: Text.Wrap
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
        color: Colors.errorColor
    }
}
