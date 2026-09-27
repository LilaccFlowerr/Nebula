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
    implicitWidth: Math.max(Theme.bar.centerMinWidth, pill.implicitWidth + Theme.bar.padding * 2)

    readonly property int maxTitleWidth: 360

    readonly property bool showMedia: Media.active
    readonly property bool showWindow: ActiveWindow.hasWindow && !showMedia
    readonly property bool empty: !showWindow && !showMedia

    Rectangle {
        id: pill
        anchors.centerIn: parent

        implicitWidth: root.empty ? Theme.button.size
                     : (root.showMedia ? media.implicitWidth : content.implicitWidth) + Theme.spacing.lg * 2
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

        Text {
            anchors.centerIn: parent
            visible: root.empty
            text: SystemInfo.osLogo
            font.family: Theme.font.logos
            font.pixelSize: Theme.button.iconSize
            color: Colors.textOnSurface
        }

        RowLayout {
            id: content
            visible: root.showWindow
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

        RowLayout {
            id: media
            visible: root.showMedia
            anchors.centerIn: parent
            spacing: Theme.spacing.sm

            ClippingRectangle {
                implicitWidth: 28
                implicitHeight: 28
                radius: Theme.radius.small
                color: Colors.surfaceContainerHigh

                Image {
                    anchors.fill: parent
                    source: Media.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                spacing: 0

                Text {
                    Layout.maximumWidth: root.maxTitleWidth
                    elide: Text.ElideRight
                    text: Media.title
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }

                Text {
                    Layout.maximumWidth: root.maxTitleWidth
                    elide: Text.ElideRight
                    text: Media.artist
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                }
            }
            WavyProgress {
                implicitWidth: 80
                progress: Media.progress
                animated: Media.playing
            }
        }
    }
}
