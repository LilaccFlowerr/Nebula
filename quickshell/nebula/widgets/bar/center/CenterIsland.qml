import QtQuick
import qs.components
import qs.services
import qs.theme
import qs.widgets.bar.center.components

Island {
    id: root
    roundLeft: true
    roundRight: true
    detach: Theme.bar.centerT
    hookLeft: true
    hookRight: true
    implicitWidth: Math.max(Theme.bar.centerMinWidth, pill.implicitWidth + pillMargin * 2)
    implicitHeight: pill.height + (Theme.bar.height - Theme.button.size)

    readonly property real pillMargin: (Theme.bar.height - Theme.button.size) / 2
    readonly property real minPillWidth: Theme.bar.centerMinWidth - pillMargin * 2

    readonly property bool isExpanded: media.expanded
    readonly property bool showMedia: Media.active
    readonly property bool showWindow: ActiveWindow.hasWindow && !showMedia
    readonly property bool empty: !showWindow && !showMedia

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.pillMargin

        implicitWidth: root.isExpanded ? media.implicitWidth
                     : Math.max(root.minPillWidth, root.showMedia ? media.implicitWidth
                        : root.empty ? emptyContent.implicitWidth + Theme.spacing.lg * 2
                        : windowContent.implicitWidth + Theme.spacing.lg * 2)
        implicitHeight: root.isExpanded ? media.implicitHeight : Theme.button.size
        radius: root.isExpanded ? Theme.radius.large : Theme.radius.full
        color: Qt.alpha(Colors.surfaceContainer, Theme.bar.pillOpacity)
        clip: true

        Behavior on implicitHeight {
            NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on implicitWidth {
            enabled: !media.resizing
            NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        EmptyContent {
            id: emptyContent
            anchors.centerIn: parent
            visible: root.empty
        }

        WindowContent {
            id: windowContent
            anchors.centerIn: parent
            visible: root.showWindow
            maxTitleWidth: 360
        }

        MediaView {
            id: media
            anchors.fill: parent
            visible: root.showMedia
        }
    }
}
