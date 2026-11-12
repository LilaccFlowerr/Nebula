import QtQuick
import qs.services
import qs.theme

Item {
    id: root

    required property string screenName
    readonly property bool here: WidgetSnap.screen === screenName

    Item {
        anchors.fill: parent
        opacity: WidgetSnap.active && root.here ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.anim.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.standard
            }
        }

        Repeater {
            model: root.here ? WidgetSnap.guides : []

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

    Repeater {
        model: 6

        Item {
            id: measure

            required property int index
            readonly property var live: WidgetSnap.dragging && root.here ? WidgetSnap.measures[index] ?? null : null
            property var entry: ({ horizontal: true, x: 0, y: 0, length: 0, value: 0 })
            readonly property bool horizontal: entry.horizontal
            readonly property real along: horizontal ? label.width : label.height
            readonly property bool fits: entry.length >= along + 2 * Theme.snap.capLength

            onLiveChanged: if (live) entry = live

            x: entry.x
            y: entry.y
            width: horizontal ? entry.length : 0
            height: horizontal ? 0 : entry.length
            opacity: live ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.standard
                }
            }

            Rectangle {
                x: measure.horizontal ? 0 : -width / 2
                y: measure.horizontal ? -height / 2 : 0
                width: measure.horizontal ? measure.width : Theme.snap.guideWidth
                height: measure.horizontal ? Theme.snap.guideWidth : measure.height
                color: Colors.primary
            }

            Repeater {
                model: 2

                Rectangle {
                    required property int index

                    x: measure.horizontal ? index * measure.width - width / 2 : -width / 2
                    y: measure.horizontal ? -height / 2 : index * measure.height - height / 2
                    width: measure.horizontal ? Theme.snap.guideWidth : Theme.snap.capLength
                    height: measure.horizontal ? Theme.snap.capLength : Theme.snap.guideWidth
                    radius: Theme.snap.guideWidth / 2
                    color: Colors.primary
                }
            }

            Rectangle {
                id: label

                x: measure.horizontal ? (measure.width - width) / 2 : measure.fits ? -width / 2 : Theme.snap.labelGap
                y: measure.horizontal ? (measure.fits ? -height / 2 : -height - Theme.snap.labelGap) : (measure.height - height) / 2
                width: number.implicitWidth + Theme.snap.labelPadding
                height: Theme.snap.labelHeight
                radius: height / 2
                color: Colors.primary

                Text {
                    id: number

                    anchors.centerIn: parent
                    text: measure.entry.value
                    color: Colors.textOnPrimary
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}
