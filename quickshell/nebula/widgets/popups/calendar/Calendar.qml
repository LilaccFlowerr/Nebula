import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme

Rectangle {
    id: root

    property bool open: false
    property int year: Time.now.getFullYear()
    property int month: Time.now.getMonth()

    readonly property date today: Time.now
    readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    readonly property var days: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;
        return Array.from({ length: 42 }, (_, i) => new Date(year, month, 1 - offset + i));
    }

    function shift(step) {
        const d = new Date(year, month + step, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    function reset() {
        year = today.getFullYear();
        month = today.getMonth();
    }

    function isToday(d) {
        return d.getDate() === today.getDate() && d.getMonth() === today.getMonth() && d.getFullYear() === today.getFullYear();
    }

    onOpenChanged: if (open) reset()

    implicitWidth: Theme.calendar.width
    implicitHeight: column.implicitHeight + Theme.spacing.lg * 2
    radius: Theme.radius.large
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.85
    transformOrigin: Item.TopRight

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

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        ColumnLayout {
            spacing: 0

            Text {
                text: root.today.toLocaleString(Qt.locale("en_US"), "dddd")
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Colors.primary
            }

            Text {
                text: root.today.toLocaleString(Qt.locale("en_US"), "MMMM d")
                font.family: Theme.font.family
                font.pixelSize: Theme.calendar.titleSize
                font.weight: Font.Bold
                color: Colors.textOnSurface
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.xs

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.sm
                text: new Date(root.year, root.month, 1).toLocaleString(Qt.locale("en_US"), "MMMM yyyy")
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                color: Colors.textOnSurfaceVariant

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.reset()
                }
            }

            IconButton {
                icon: "chevron_left"
                onClicked: root.shift(-1)
            }

            IconButton {
                icon: "chevron_right"
                onClicked: root.shift(1)
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 2

            Repeater {
                model: root.weekdays

                Text {
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: Theme.calendar.cellSize
                    Layout.preferredHeight: Theme.calendar.cellSize * 0.7
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    color: Colors.textOnSurfaceVariant
                }
            }

            Repeater {
                model: root.days

                Item {
                    id: day

                    required property var modelData
                    readonly property bool current: modelData.getMonth() === root.month
                    readonly property bool today: root.isToday(modelData)

                    Layout.fillWidth: true
                    Layout.preferredWidth: Theme.calendar.cellSize
                    Layout.preferredHeight: Theme.calendar.cellSize

                    MaterialShape {
                        anchors.centerIn: parent
                        implicitSize: Theme.calendar.cellSize
                        shape: MaterialShape.Cookie9Sided
                        color: Colors.primary
                        visible: day.today
                    }

                    Text {
                        anchors.centerIn: parent
                        text: day.modelData.getDate()
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: day.today ? Font.Bold : Font.Normal
                        color: day.today ? Colors.textOnPrimary : Colors.textOnSurface
                        opacity: day.current ? 1 : 0.35
                    }
                }
            }
        }
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.shift(event.angleDelta.y > 0 ? -1 : 1)
    }
}
