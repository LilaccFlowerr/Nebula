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

    Rectangle {
        id: pill
        anchors.centerIn: parent

        implicitWidth: content.implicitWidth + Theme.spacing.lg * 2
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

        RowLayout {
            id: content
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
