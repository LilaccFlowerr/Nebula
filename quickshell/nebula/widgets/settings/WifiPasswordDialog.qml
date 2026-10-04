import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    readonly property bool shown: Wifi.prompt !== null
    property string name: ""

    onShownChanged: {
        if (!shown) return;
        name = Wifi.prompt.name;
        field.focusField();
    }

    visible: opacity > 0
    opacity: shown ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.large + Theme.spacing.sm
        color: Colors.scrim
        opacity: Theme.launcher.dim

        MouseArea {
            anchors.fill: parent
            onClicked: Wifi.prompt = null
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Theme.settings.dialogWidth
        height: column.implicitHeight + Theme.spacing.xl * 2
        radius: Theme.radius.large
        color: Colors.surfaceContainerHigh
        scale: root.shown ? 1 : 0.92

        Behavior on scale {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacing.xl
            spacing: Theme.spacing.md

            Text {
                text: "lock"
                font.family: Theme.font.icons
                font.pixelSize: Theme.settings.titleSize
                color: Colors.primary
            }

            Text {
                Layout.fillWidth: true
                text: "Connect to " + root.name
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large + 4
                font.weight: Font.Bold
                color: Colors.textOnSurface
            }

            Text {
                Layout.fillWidth: true
                text: "This network is secured. Enter its password to join."
                wrapMode: Text.Wrap
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Colors.textOnSurfaceVariant
            }

            PasswordField {
                id: field
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.sm
                busy: Wifi.pending !== "" && Wifi.pending === root.name
                error: Wifi.pending === "" ? Wifi.error : ""
                onSubmitted: password => Wifi.connect(Wifi.prompt, password)
            }

            Text {
                Layout.alignment: Qt.AlignRight
                Layout.topMargin: Theme.spacing.sm
                text: "Cancel"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                color: Colors.primary

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -Theme.spacing.sm
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wifi.prompt = null
                }
            }
        }
    }
}
