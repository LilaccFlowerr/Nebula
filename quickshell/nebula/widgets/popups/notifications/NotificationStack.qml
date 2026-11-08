import QtQuick
import Quickshell
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property bool open: false
    readonly property bool hovered: hover.hovered
    readonly property int count: Math.min(Notifications.shown.length, Theme.toast.maxShown)
    readonly property bool expanded: hovered && count > 1
    readonly property real frontHeight: heightAt(0)
    property var heights: ({})

    function setHeight(key, h) {
        heights = Object.assign({}, heights, { [key]: h });
    }

    function heightAt(index) {
        return heights[Notifications.shown[index]] ?? 0;
    }

    function offsetOf(index) {
        if (!expanded) return 0;
        let y = 0;
        for (let i = 0; i < index; i++) y += heightAt(i) + Theme.toast.gap;
        return y;
    }

    implicitWidth: Theme.toast.width
    implicitHeight: count === 0 ? 0
        : expanded ? offsetOf(count - 1) + heightAt(count - 1)
        : frontHeight + Math.min(count - 1, Theme.toast.maxPeek) * Theme.toast.peek

    visible: opacity > 0
    opacity: open && count > 0 ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.medium }
    }
    Behavior on implicitHeight {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
    }

    HoverHandler {
        id: hover
    }

    Repeater {
        model: Theme.toast.maxPeek

        Item {
            id: tab

            required property int index
            readonly property int depth: index + 1
            readonly property real height2: Theme.toast.radius * 2

            x: depth * Theme.toast.peekInset
            y: root.frontHeight + index * Theme.toast.peek
            z: -10 - depth
            width: root.width - x * 2
            height: Theme.toast.peek
            clip: true
            visible: opacity > 0
            opacity: !root.expanded && root.count > depth ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.fast }
            }

            GlassRect {
                y: tab.height - tab.height2
                width: tab.width
                height: tab.height2
                radius: Theme.toast.radius
                light: 0
                tint: Theme.glass.tint - tab.depth * Theme.toast.peekFade
                fill: Colors.primaryContainer
            }
        }
    }

    Repeater {
        model: ScriptModel {
            values: Notifications.shown
        }

        NotificationCard {
            id: card

            required property string modelData
            required property int index

            readonly property bool leaving: Notifications.leaving.includes(modelData)
            readonly property real away: root.width + Theme.bar.floatMargin * 2
            readonly property bool behind: !root.expanded && index > 0
            property real slide: away
            property bool tucked: false
            property real presence: tucked ? 0 : 1
            property real ink: behind ? 0 : 1

            key: modelData
            canOpen: root.expanded || root.count === 1
            z: -index
            width: root.width
            visible: index < Theme.toast.maxShown
            y: root.offsetOf(index)
            scale: 0.94 + 0.06 * presence
            transformOrigin: Item.Top
            contentOpacity: ink
            opacity: presence * (1 - slide / away)
            transform: Translate { x: card.slide }

            onImplicitHeightChanged: root.setHeight(modelData, implicitHeight)
            onBehindChanged: {
                if (behind) {
                    tuckTimer.restart();
                } else {
                    tuckTimer.stop();
                    tucked = false;
                }
            }
            onLeavingChanged: {
                if (leaving) {
                    leaveAnim.restart();
                } else {
                    leaveAnim.stop();
                    slide = 0;
                }
            }
            Component.onCompleted: {
                root.setHeight(modelData, implicitHeight);
                tucked = behind;
                slide = 0;
            }

            Timer {
                id: tuckTimer
                interval: Theme.anim.island
                onTriggered: card.tucked = true
            }

            Behavior on slide {
                enabled: !drag.active && !card.leaving
                NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
            }
            Behavior on y {
                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
            }
            Behavior on ink {
                NumberAnimation { duration: Theme.anim.fast }
            }
            Behavior on presence {
                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
            }

            NumberAnimation {
                id: leaveAnim
                target: card
                property: "slide"
                to: card.away
                duration: Theme.anim.medium
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.emphasizedAccel
                onFinished: Notifications.finish(card.modelData)
            }

            DragHandler {
                id: drag
                target: null
                enabled: !card.leaving
                yAxis.enabled: false
                onTranslationChanged: if (active) card.slide = Math.max(0, translation.x)
                onActiveChanged: {
                    if (active) return;
                    if (card.slide > card.width * Theme.toast.swipeThreshold) Notifications.dismiss(card.modelData);
                    else card.slide = 0;
                }
            }
        }
    }
}
