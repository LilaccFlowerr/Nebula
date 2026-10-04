import QtQuick
import qs.theme

Rectangle {
    id: root

    property real value: 0
    property real from: 0
    property real to: 100
    property real step: 1
    property real factor: 1
    property int decimals: 0
    property string suffix: ""
    property bool cancelled: false

    signal edited(real value)

    function plain(v) {
        return (v / factor).toFixed(decimals).replace(/(\.\d*?)0+$/, "$1").replace(/\.$/, "");
    }

    function format(v) {
        return plain(v) + suffix;
    }

    function commit(v) {
        const clamped = Math.max(from, Math.min(to, Math.round(v / step) * step));
        if (!isNaN(clamped)) edited(clamped);
    }

    implicitWidth: Theme.settings.fieldWidth
    implicitHeight: Theme.button.size - Theme.spacing.xs
    radius: height / 2
    color: input.activeFocus ? Colors.surfaceContainerHighest : Colors.surfaceContainer
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Colors.primary : Colors.outlineVariant

    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.sm
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        text: root.format(root.value)
        selectByMouse: true
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        font.weight: Font.DemiBold
        color: Colors.textOnSurface
        selectionColor: Colors.primary
        selectedTextColor: Colors.textOnPrimary

        onActiveFocusChanged: {
            if (activeFocus) {
                text = root.plain(root.value);
                selectAll();
            } else {
                text = Qt.binding(() => root.format(root.value));
            }
        }

        onEditingFinished: {
            if (!root.cancelled) root.commit(parseFloat(text.replace(",", ".")) * root.factor);
            root.cancelled = false;
        }

        onAccepted: focus = false

        Keys.onEscapePressed: event => {
            root.cancelled = true;
            focus = false;
            event.accepted = true;
        }

        Keys.onUpPressed: event => {
            root.commit(root.value + root.step);
            text = root.plain(root.value);
            event.accepted = true;
        }

        Keys.onDownPressed: event => {
            root.commit(root.value - root.step);
            text = root.plain(root.value);
            event.accepted = true;
        }
    }
}
