import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

Island {
    detach: Theme.bar.leftT
    hookRight: true
    edgeLeft: true
    roundRight: true
    implicitWidth: row.implicitWidth + Theme.bar.padding * 2

    WheelHandler {
        property real delta: 0

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            delta += event.angleDelta.y;
            if (Math.abs(delta) < 120) return;
            if (delta < 0) Workspaces.next();
            else Workspaces.previous();
            delta = 0;
        }
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.padding
        spacing: Theme.bar.gap

        Item {
            id: logo

            readonly property bool image: Settings.bar.logoMode === "image" && Settings.bar.logoImage !== ""
            readonly property bool text: Settings.bar.logoMode === "text"

            visible: Settings.bar.osLogo
            implicitWidth: image ? Theme.button.size : Math.max(Theme.button.size, glyph.implicitWidth + Theme.spacing.md)
            implicitHeight: Theme.button.size

            Text {
                id: glyph
                anchors.centerIn: parent
                visible: !logo.image
                text: SystemInfo.logo
                font.family: logo.text ? Theme.font.family : Theme.font.logos
                font.pixelSize: logo.text ? Theme.font.clock : Theme.button.iconSize + 2
                font.weight: Font.DemiBold
                color: Colors.primary
            }

            Image {
                id: picture
                anchors.centerIn: parent
                width: Theme.button.iconSize + 4
                height: width
                visible: false
                source: logo.image ? Wallpaper.url(Settings.bar.logoImage) : ""
                sourceSize: Qt.size(width * 2, height * 2)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            MultiEffect {
                anchors.fill: picture
                source: picture
                visible: logo.image
                colorization: 1
                colorizationColor: Colors.primary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: GlobalStates.toggleLauncher()
            }
        }

        Repeater {
            model: Workspaces.groupSize

            WorkspaceButton {
                required property int index
                wsId: Workspaces.firstId + index
            }
        }
    }
}