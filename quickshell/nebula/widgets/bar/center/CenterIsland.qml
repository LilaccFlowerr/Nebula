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

    readonly property bool showWindow: ActiveWindow.hasWindow
    readonly property bool empty: !showWindow

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.pillMargin

        implicitWidth: Math.max(root.minPillWidth, (root.empty ? emptyContent.implicitWidth : windowContent.implicitWidth) + Theme.spacing.lg * 2)
        implicitHeight: Theme.button.size
        radius: Theme.radius.full
        color: Qt.alpha(Colors.surfaceContainer, Theme.bar.pillOpacity)
        clip: true

        Behavior on implicitWidth {
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
    }
}
