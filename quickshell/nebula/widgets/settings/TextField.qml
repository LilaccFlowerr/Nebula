import QtQuick
import qs.theme

Rectangle {
    id: root

    property string text: ""
    property string placeholder: ""

    signal edited(string text)

    implicitWidth: Theme.settings.fieldWidth * 2
    implicitHeight: Theme.button.size - Theme.spacing.xs
    radius: height / 2
    color: input.activeFocus ? Colors.surfaceContainerHighest : Colors.surfaceContainer
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Colors.primary : Colors.outlineVariant

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md
        anchors.rightMargin: Theme.spacing.md
        verticalAlignment: TextInput.AlignVCenter
        text: root.text
        selectByMouse: true
        clip: true
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        font.weight: Font.DemiBold
        color: Colors.textOnSurface
        selectionColor: Colors.primary
        selectedTextColor: Colors.textOnPrimary
        onEditingFinished: if (text.trim() !== root.text) root.edited(text.trim())
        onAccepted: focus = false

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: root.placeholder
            font: input.font
            color: Colors.textOnSurfaceVariant
        }
    }
}
