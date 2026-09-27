import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

Island {
    id: root
    roundLeft: true
    roundRight: true
    implicitWidth: pill.implicitWidth + Theme.bar.padding * 2

    
    readonly property int maxTitleWidth: 360

    // No window on this workspace → collapse into a dot with the OS logo
    readonly property bool empty: !ActiveWindow.hasWindow

    Rectangle {
        id: pill
        anchors.centerIn: parent

        implicitWidth: root.empty ? Theme.button.size : content.implicitWidth + Theme.spacing.lg * 2
        implicitHeight: Theme.button.size
        radius: Theme.radius.full
        color: Colors.surfaceContainer
        clip: true


        Behavior on implicitWidth {
            NumberAnimation {
                duration: Theme.anim.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.standard
            }
        }

        // OS logo, only on an empty workspace
        Text {
            anchors.centerIn: parent
            visible: root.empty
            text: SystemInfo.osLogo
            font.family: Theme.font.logos
            font.pixelSize: Theme.button.iconSize
            color: Colors.textOnSurface      // same light color as the rest of the bar text
        }

        RowLayout {
            id: content
            visible: !root.empty
            anchors.centerIn: parent
            spacing: Theme.spacing.xs

            IconImage {
                source: ActiveWindow.icon
                implicitSize: Theme.button.iconSize
                visible: source !== ""
            }

            Text {
                id: title
                Layout.maximumWidth: root.maxTitleWidth
                elide: Text.ElideRight

                text: ActiveWindow.title
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
            }
        }
    }
}
