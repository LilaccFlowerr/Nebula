import QtQuick
import qs.services
import qs.theme

Item {
    id: root

    required property string screenName
    property size room: Qt.size(0, 0)
    property point origin: Qt.point(0, 0)

    readonly property bool shown: Widgets.editing && Widgets.editScreen === screenName
    readonly property bool hovered: shown && (over.hovered || drag.active)
    readonly property var buttons: [
        { key: "add", icon: "add", text: "Add" },
        { key: "layouts", icon: "dashboard", text: "Layouts" },
        { key: "grid", icon: "grid_4x4", text: "", on: Settings.widgets.grid },
        { key: "undo", icon: "undo", text: "", faded: !Widgets.canUndo },
        { key: "redo", icon: "redo", text: "", faded: !Widgets.canRedo },
        { key: "done", icon: "check", text: "Done", filled: true }
    ]

    readonly property real button: Theme.edit.button
    readonly property real pad: Theme.edit.padding
    readonly property real gap: Theme.edit.gap
    readonly property real margin: Theme.edit.margin

    readonly property string edge: drag.active ? nearest(centerX, centerY) : Settings.widgets.toolbarEdge
    readonly property bool upright: edge === "left" || edge === "right"
    property real t: upright ? 1 : 0
    property var labels: []

    property real centerX: 0
    property real centerY: 0
    property real startX: 0
    property real startY: 0
    property real settle: 0
    property real fromX: 0
    property real fromY: 0

    readonly property real flatWidth: pad * 2 + offset(buttons.length) - gap
    readonly property real tallHeight: pad * 2 + buttons.length * (button + gap) - gap
    readonly property real restX: edge === "left" ? margin
        : edge === "right" ? room.width - width - margin
        : (room.width - width) / 2
    readonly property real restY: edge === "top" ? Theme.bar.zone + margin
        : edge === "bottom" ? room.height - height - margin
        : (room.height - height) / 2

    function nearest(x, y) {
        const options = [
            { edge: "left", away: x },
            { edge: "right", away: room.width - x },
            { edge: "top", away: y },
            { edge: "bottom", away: room.height - y }
        ];
        return options.reduce((best, o) => o.away < best.away ? o : best).edge;
    }

    function span(index) {
        return button + (labels[index] ?? 0) * (1 - t);
    }

    function offset(index) {
        let total = 0;
        for (let i = 0; i < index; i++) total += span(i) + gap;
        return total;
    }

    function setLabel(index, width) {
        if (labels[index] === width) return;
        const next = labels.slice();
        next[index] = width;
        labels = next;
    }

    function act(key, item) {
        if (key === "done") {
            Widgets.stopEdit();
            return;
        }
        if (key === "grid") {
            Settings.widgets.grid = !Settings.widgets.grid;
            return;
        }
        if (key === "undo") {
            Widgets.undo();
            return;
        }
        if (key === "redo") {
            Widgets.redo();
            return;
        }
        const spot = menuSpot(item);
        Widgets.openDesk(screenName, origin.x + spot.x, origin.y + spot.y, key, spot.alignX, spot.alignY);
    }

    function menuSpot(item) {
        const space = Theme.spacing.sm;
        if (edge === "bottom") return { x: x + item.x, y: y - space, alignX: 0, alignY: 1 };
        if (edge === "top") return { x: x + item.x, y: y + height + space, alignX: 0, alignY: 0 };
        if (edge === "left") return { x: x + width + space, y: y + item.y, alignX: 0, alignY: 0 };
        return { x: x - space, y: y + item.y, alignX: 1, alignY: 0 };
    }

    width: flatWidth * (1 - t) + (button + pad * 2) * t
    height: (button + pad * 2) * (1 - t) + tallHeight * t
    x: drag.active ? centerX - width / 2 : restX + settle * (fromX - restX)
    y: drag.active ? centerY - height / 2 : restY + settle * (fromY - restY)
    visible: opacity > 0
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.9

    Behavior on t {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    NumberAnimation {
        id: settling
        target: root
        property: "settle"
        from: 1
        to: 0
        duration: Theme.anim.slow
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.emphasizedDecel
    }

    Rectangle {
        anchors.fill: parent
        radius: (root.button + root.pad * 2) / 2
        color: Qt.alpha(Colors.surfaceContainer, 0.97)
        border.width: 1
        border.color: Colors.outlineVariant
    }

    HoverHandler {
        id: over
    }

    DragHandler {
        id: drag
        target: null
        cursorShape: Qt.ClosedHandCursor

        onActiveChanged: {
            if (active) {
                settling.stop();
                root.settle = 0;
                root.startX = root.x + root.width / 2;
                root.startY = root.y + root.height / 2;
                root.centerX = root.startX;
                root.centerY = root.startY;
                return;
            }
            const dropX = root.centerX - root.width / 2;
            const dropY = root.centerY - root.height / 2;
            Settings.widgets.toolbarEdge = root.nearest(root.centerX, root.centerY);
            root.fromX = dropX;
            root.fromY = dropY;
            settling.restart();
        }

        onTranslationChanged: {
            if (!active) return;
            root.centerX = root.startX + translation.x;
            root.centerY = root.startY + translation.y;
        }
    }

    Repeater {
        model: root.buttons

        Rectangle {
            id: tool

            required property var modelData
            required property int index

            x: (root.pad + root.offset(index)) * (1 - root.t) + root.pad * root.t
            y: root.pad * (1 - root.t) + (root.pad + index * (root.button + root.gap)) * root.t
            width: root.span(index)
            height: root.button
            radius: root.button / 2
            clip: true
            opacity: modelData.faded ? 0.4 : 1
            color: modelData.filled ? Colors.primary
                : modelData.on ? Colors.primaryContainer
                : hover.hovered ? Colors.surfaceContainerHighest
                : Colors.surfaceContainerHigh

            readonly property color ink: modelData.filled ? Colors.textOnPrimary
                : modelData.on ? Colors.textOnPrimaryContainer
                : Colors.textOnSurface

            Text {
                id: glyph

                x: (root.button - width) / 2 + (label.text !== "" ? Theme.edit.labelGap : 0) * (1 - root.t)
                anchors.verticalCenter: parent.verticalCenter
                text: tool.modelData.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: tool.ink
            }

            Text {
                id: label

                x: glyph.x + glyph.width + Theme.edit.labelGap
                anchors.verticalCenter: parent.verticalCenter
                text: tool.modelData.text
                opacity: 1 - root.t
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                color: tool.ink

                readonly property real room: text === "" ? 0 : implicitWidth + Theme.edit.labelPadding

                onRoomChanged: root.setLabel(tool.index, room)
                Component.onCompleted: root.setLabel(tool.index, room)
            }

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                gesturePolicy: TapHandler.DragThreshold
                onTapped: root.act(tool.modelData.key, tool)
            }
        }
    }
}
