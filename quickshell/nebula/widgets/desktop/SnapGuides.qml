import QtQuick
import qs.services
import qs.theme

Item {
    id: root

    required property string screenName
    readonly property bool shown: WidgetSnap.active && WidgetSnap.screen === screenName

    opacity: shown ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.anim.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    Repeater {
        model: WidgetSnap.screen === root.screenName ? WidgetSnap.guides : []

        Rectangle {
            required property var modelData
            readonly property real length: modelData.to - modelData.from + 2 * Theme.snap.guideOverhang

            x: modelData.vertical ? modelData.at - width / 2 : modelData.from - Theme.snap.guideOverhang
            y: modelData.vertical ? modelData.from - Theme.snap.guideOverhang : modelData.at - height / 2
            width: modelData.vertical ? Theme.snap.guideWidth : length
            height: modelData.vertical ? length : Theme.snap.guideWidth
            radius: Theme.snap.guideWidth / 2
            color: Colors.primary
        }
    }
}
