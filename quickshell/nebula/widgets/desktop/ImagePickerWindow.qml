import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.services
import qs.theme

PanelWindow {
    id: window

    property real progress: Widgets.pickerOpen ? 1 : 0

    Behavior on progress {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
    }

    visible: Widgets.pickerOpen || progress > 0
    screen: Widgets.screenNamed(Widgets.pickerScreen)

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:imagepicker"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.scrim, Theme.imagePicker.backdropDim * window.progress)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: Widgets.closePicker()
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: Widgets.pickerOpen
        onActivated: Widgets.closePicker()
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: Math.min(Theme.imagePicker.width, window.width - Theme.spacing.xl * 2)
        height: Math.min(Theme.imagePicker.height, window.height - Theme.spacing.xl * 2)
        radius: Theme.radius.large
        color: Qt.alpha(Colors.surfaceContainer, 0.97)
        border.width: 1
        border.color: Colors.outlineVariant
        opacity: window.progress
        scale: Theme.imagePicker.openScale + (1 - Theme.imagePicker.openScale) * window.progress

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            spacing: Theme.spacing.md

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: Widgets.pickerTarget !== "" ? "Change image" : "Add an image"
                        color: Colors.textOnSurface
                        font.family: Theme.font.family
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Widgets.pickerTarget !== "" ? "Click one to swap it in" : "Click one to put it on your desktop"
                        color: Colors.textOnSurfaceVariant
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                    }
                }

                IconButton {
                    implicitWidth: 40
                    implicitHeight: 40
                    icon: "close"
                    onClicked: Widgets.closePicker()
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: browser.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ImageBrowser {
                    id: browser
                    width: parent.width
                    columns: Theme.imagePicker.columns
                    onChosen: path => Widgets.pickImage(path)
                }
            }
        }
    }
}
