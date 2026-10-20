import QtQuick
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property string shapeName: "Cookie9Sided"
    property real baseSize: 200
    property string colorRole: "tertiary"
    property string openShapeName: ""
    property bool expanded: false
    readonly property var colors: Widgets.palette(colorRole)
    readonly property real expandedScale: 1.8

    property real size: expanded ? baseSize * expandedScale : baseSize

    Behavior on size {
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    readonly property real t: Math.max(0, Math.min(1, (size - baseSize) / (baseSize * (expandedScale - 1))))
    readonly property real shownGrid: Math.max(0, Math.min(1, t * 2 - 1))
    readonly property real shownDate: Math.max(0, Math.min(1, 1 - t * 2))

    readonly property date today: Time.now
    property int year: today.getFullYear()
    property int month: today.getMonth()
    property int direction: 1
    property real slide: 0
    property real gridOpacity: 1
    readonly property bool showingToday: year === today.getFullYear() && month === today.getMonth()
    readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    readonly property var days: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;
        return Array.from({ length: 42 }, (_, i) => new Date(year, month, 1 - offset + i));
    }

    readonly property real inner: size * 0.68
    readonly property real innerX: (size - inner) / 2
    readonly property real innerY: (size - inner) / 2
    readonly property real headerHeight: inner * 0.14
    readonly property real weekdayHeight: inner * 0.1
    readonly property real cellWidth: inner / 7
    readonly property real cellHeight: (inner - headerHeight - weekdayHeight) / 6

    function go(y, m) {
        const d = new Date(y, m, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    function shift(step) {
        if (swap.running) swap.complete();
        direction = step;
        swap.target = new Date(year, month + step, 1);
        swap.restart();
    }

    function backToToday() {
        if (showingToday) return;
        const back = year * 12 + month > today.getFullYear() * 12 + today.getMonth() ? -1 : 1;
        if (swap.running) swap.complete();
        direction = back;
        swap.target = new Date(today.getFullYear(), today.getMonth(), 1);
        swap.restart();
    }

    function isToday(d) {
        return d.getDate() === today.getDate() && d.getMonth() === today.getMonth() && d.getFullYear() === today.getFullYear();
    }

    onExpandedChanged: {
        if (expanded) return;
        swap.stop();
        slide = 0;
        gridOpacity = 1;
        go(today.getFullYear(), today.getMonth());
    }

    SequentialAnimation {
        id: swap

        property date target: new Date()

        ParallelAnimation {
            NumberAnimation { target: root; property: "slide"; to: -root.direction * Theme.calendar.slideDistance; duration: Theme.anim.fast; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "gridOpacity"; to: 0; duration: Theme.anim.fast; easing.type: Easing.InCubic }
        }
        ScriptAction {
            script: {
                root.go(swap.target.getFullYear(), swap.target.getMonth());
                root.slide = root.direction * Theme.calendar.slideDistance;
            }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "slide"; to: 0; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
            NumberAnimation { target: root; property: "gridOpacity"; to: 1; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }
    }

    implicitWidth: size
    implicitHeight: size

    MaterialShape {
        anchors.fill: parent
        shape: MaterialShape[root.expanded && root.openShapeName !== "" ? root.openShapeName : root.shapeName] ?? MaterialShape.Cookie9Sided
        color: root.colors.fill
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.OutBack
        animationEasing.overshoot: Theme.anim.overshoot
    }

    Column {
        anchors.centerIn: parent
        spacing: -root.baseSize * 0.02
        opacity: root.shownDate
        visible: opacity > 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.today, "dddd")
            font.family: Theme.font.family
            font.pixelSize: root.baseSize * 0.095
            font.weight: Font.Medium
            color: root.colors.text
            opacity: 0.8
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.today, "d")
            font.family: Theme.font.family
            font.pixelSize: root.baseSize * 0.36
            font.weight: Font.DemiBold
            color: root.colors.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.today, "MMMM")
            font.family: Theme.font.family
            font.pixelSize: root.baseSize * 0.095
            font.weight: Font.Medium
            color: root.colors.text
            opacity: 0.8
        }
    }

    Item {
        x: root.innerX
        y: root.innerY
        width: root.inner
        height: root.inner
        opacity: root.shownGrid
        visible: opacity > 0

        Item {
            x: root.headerHeight + root.slide * root.inner
            width: parent.width - root.headerHeight * 2
            height: root.headerHeight
            opacity: root.gridOpacity

            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
                font.family: Theme.font.family
                font.pixelSize: root.inner * 0.075
                font.weight: Font.DemiBold
                color: root.colors.text
            }
        }

        Text {
            width: root.headerHeight
            height: root.headerHeight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "chevron_left"
            font.family: Theme.font.icons
            font.pixelSize: root.headerHeight * 0.8
            color: root.colors.text
        }

        Text {
            x: parent.width - root.headerHeight
            width: root.headerHeight
            height: root.headerHeight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "chevron_right"
            font.family: Theme.font.icons
            font.pixelSize: root.headerHeight * 0.8
            color: root.colors.text
        }

        Row {
            y: root.headerHeight

            Repeater {
                model: root.weekdays

                Text {
                    required property string modelData

                    width: root.cellWidth
                    height: root.weekdayHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    font.family: Theme.font.family
                    font.pixelSize: root.inner * 0.058
                    font.weight: Font.Medium
                    color: root.colors.text
                    opacity: 0.65
                }
            }
        }

        Grid {
            x: root.slide * root.inner
            y: root.headerHeight + root.weekdayHeight
            columns: 7
            opacity: root.gridOpacity

            Repeater {
                model: root.days

                Item {
                    id: cell

                    required property date modelData
                    readonly property bool today: root.isToday(modelData)
                    readonly property bool inMonth: modelData.getMonth() === root.month

                    width: root.cellWidth
                    height: root.cellHeight

                    MaterialShape {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 1.05
                        height: width
                        shape: MaterialShape.Cookie9Sided
                        color: root.colors.text
                        visible: cell.today
                    }

                    Text {
                        anchors.centerIn: parent
                        text: cell.modelData.getDate()
                        font.family: Theme.font.family
                        font.pixelSize: root.inner * 0.066
                        font.weight: cell.today ? Font.DemiBold : Font.Normal
                        color: cell.today ? root.colors.fill : root.colors.text
                        opacity: cell.inMonth || cell.today ? 1 : 0.35
                    }
                }
            }
        }
    }

    TapHandler {
        onTapped: eventPoint => {
            const p = eventPoint.position;
            const inHeader = root.expanded && root.shownGrid > 0.5
                && p.y >= root.innerY && p.y <= root.innerY + root.headerHeight
                && p.x >= root.innerX && p.x <= root.innerX + root.inner;
            if (!inHeader) {
                root.expanded = !root.expanded;
                return;
            }
            if (p.x < root.innerX + root.headerHeight) root.shift(-1);
            else if (p.x > root.innerX + root.inner - root.headerHeight) root.shift(1);
            else root.backToToday();
        }
    }

    WheelHandler {
        property real delta: 0

        enabled: root.expanded
        onWheel: event => {
            delta += event.angleDelta.y;
            if (Math.abs(delta) < 120) return;
            root.shift(delta < 0 ? 1 : -1);
            delta = 0;
        }
    }
}
