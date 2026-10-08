import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme

Rectangle {
    id: root

    component Detail: Row {
        id: detail

        property string icon: ""
        property string value: ""

        spacing: Theme.spacing.xs

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: detail.icon
            font.family: Theme.font.icons
            font.pixelSize: Theme.calendar.detailIconSize
            color: Colors.primary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: detail.value
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            color: Colors.textOnSurface
        }
    }

    property bool open: false
    property int year: Time.now.getFullYear()
    property int month: Time.now.getMonth()
    property int direction: 1
    property real slide: 0
    property real gridOpacity: 1

    readonly property date today: Time.now
    readonly property bool showingToday: year === today.getFullYear() && month === today.getMonth()
    readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    readonly property var days: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;
        return Array.from({ length: 42 }, (_, i) => new Date(year, month, 1 - offset + i));
    }

    function go(y, m) {
        const d = new Date(y, m, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    function shift(step) {
        if (swap.running) {
            swap.complete();
        }
        direction = step;
        swap.target = new Date(year, month + step, 1);
        swap.restart();
    }

    function reset() {
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

    onOpenChanged: {
        if (!open) return;
        go(today.getFullYear(), today.getMonth());
        Weather.refreshIfOld();
    }

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

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        RowLayout {
            spacing: Theme.spacing.md

            MaterialShape {
                implicitSize: Theme.calendar.dayShapeSize
                implicitWidth: Theme.calendar.dayShapeSize
                implicitHeight: Theme.calendar.dayShapeSize
                shape: MaterialShape.Cookie12Sided
                color: Colors.primaryContainer

                Text {
                    anchors.centerIn: parent
                    text: root.today.toLocaleString(Qt.locale("en_US"), "dd")
                    font.family: Theme.font.family
                    font.pixelSize: Theme.calendar.dayNumberSize
                    font.weight: Font.Bold
                    color: Colors.textOnPrimaryContainer
                }
            }

            ColumnLayout {
                spacing: 0

                Text {
                    text: root.today.toLocaleString(Qt.locale("en_US"), "dddd")
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                    color: Colors.textOnSurface
                }

                Text {
                    text: root.today.toLocaleString(Qt.locale("en_US"), "MMMM yyyy")
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Colors.textOnSurfaceVariant
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.xs

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.sm
                implicitHeight: monthLabel.implicitHeight
                clip: true

                Text {
                    id: monthLabel
                    x: root.slide * parent.width
                    opacity: root.gridOpacity
                    text: new Date(root.year, root.month, 1).toLocaleString(Qt.locale("en_US"), root.year === root.today.getFullYear() ? "MMMM" : "MMMM yyyy")
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    font.weight: Font.DemiBold
                    color: Colors.textOnSurfaceVariant
                }
            }

            IconButton {
                visible: !root.showingToday
                icon: "today"
                onClicked: root.reset()
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
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: grid.implicitHeight
            clip: true

            GridLayout {
                id: grid
                x: root.slide * parent.width
                width: parent.width
                opacity: root.gridOpacity
                columns: 7
                rowSpacing: 2
                columnSpacing: 2

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

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.xs
            implicitHeight: (weather.visible ? weather.implicitHeight : empty.implicitHeight) + Theme.spacing.md * 2
            radius: Theme.radius.large - Theme.spacing.xs
            color: Colors.surfaceContainer

            RowLayout {
                id: empty

                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                visible: !weather.visible
                spacing: Theme.spacing.md

                MaterialShape {
                    implicitSize: Theme.calendar.emptyShapeSize
                    implicitWidth: Theme.calendar.emptyShapeSize
                    implicitHeight: Theme.calendar.emptyShapeSize
                    shape: Weather.error !== "" ? MaterialShape.Ghostish : MaterialShape.Cookie9Sided
                    color: Colors.secondaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: !Weather.enabled ? "location_off" : Weather.error !== "" ? "cloud_off" : "cloud_sync"
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.calendar.forecastIconSize
                        color: Colors.textOnSecondaryContainer
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: !Weather.enabled ? "No city yet" : Weather.error !== "" ? "No weather" : "Getting the weather"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: Font.DemiBold
                        color: Colors.textOnSurface
                    }

                    Text {
                        Layout.fillWidth: true
                        text: !Weather.enabled ? "Add your city to see the weather here" : Weather.error !== "" ? Weather.error : "One moment…"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        color: Colors.textOnSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    visible: !Weather.enabled || Weather.error !== ""
                    implicitWidth: setLabel.implicitWidth + Theme.spacing.lg * 2
                    implicitHeight: Theme.button.size - Theme.spacing.xs
                    radius: height / 2
                    color: setMouse.containsMouse ? Qt.lighter(Colors.primary, 1.1) : Colors.primary

                    Text {
                        id: setLabel
                        anchors.centerIn: parent
                        text: Weather.enabled ? "Change" : "Set city"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        font.weight: Font.DemiBold
                        color: Colors.textOnPrimary
                    }

                    MouseArea {
                        id: setMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: GlobalStates.openSettings("bar", "right")
                    }
                }
            }

            ColumnLayout {
                id: weather

                readonly property var now: Weather.current ? Weather.describe(Weather.current.code, Weather.current.day) : null

                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                visible: Weather.enabled && Weather.current !== null
                spacing: Theme.spacing.md

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.md

                    MaterialShape {
                        implicitSize: Theme.calendar.weatherShapeSize
                        implicitWidth: Theme.calendar.weatherShapeSize
                        implicitHeight: Theme.calendar.weatherShapeSize
                        shape: weather.now?.shape ?? MaterialShape.Circle
                        color: Colors.primaryContainer

                        Text {
                            anchors.centerIn: parent
                            text: weather.now?.icon ?? ""
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.calendar.weatherIconSize
                            color: Colors.textOnPrimaryContainer
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        RowLayout {
                            spacing: Theme.spacing.sm

                            Text {
                                text: (Weather.current?.temp ?? "") + "°"
                                font.family: Theme.font.family
                                font.pixelSize: Theme.calendar.weatherTempSize
                                font.weight: Font.Bold
                                color: Colors.textOnSurface
                            }

                            Text {
                                Layout.alignment: Qt.AlignBottom
                                Layout.bottomMargin: Theme.spacing.xs
                                text: Weather.today ? "↑" + Weather.today.max + "°  ↓" + Weather.today.min + "°" : ""
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.small
                                color: Colors.textOnSurfaceVariant
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (weather.now?.text ?? "") + " in " + Weather.place
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            color: Colors.textOnSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    rowSpacing: Theme.spacing.sm
                    columnSpacing: Theme.spacing.sm

                    Detail { Layout.fillWidth: true; Layout.preferredWidth: 1; icon: "thermostat"; value: "Feels " + (Weather.current?.feels ?? "") + "°" }
                    Detail { Layout.fillWidth: true; Layout.preferredWidth: 1; icon: "humidity_percentage"; value: (Weather.current?.humidity ?? "") + "%" }
                    Detail { Layout.fillWidth: true; Layout.preferredWidth: 1; icon: "air"; value: (Weather.current?.wind ?? "") + " km/h" }
                    Detail { Layout.fillWidth: true; Layout.preferredWidth: 1; icon: "umbrella"; value: (Weather.today?.rain ?? 0) + "% rain" }
                    Detail { Layout.fillWidth: true; Layout.preferredWidth: 1; icon: "wb_twilight"; value: Weather.today?.sunrise ?? "" }
                    Detail { Layout.fillWidth: true; Layout.preferredWidth: 1; icon: "bedtime"; value: Weather.today?.sunset ?? "" }
                }

                Row {
                    id: days

                    Layout.fillWidth: true
                    spacing: Theme.spacing.xs

                    Repeater {
                        model: Weather.days

                        Rectangle {
                            id: forecast

                            required property var modelData
                            required property int index
                            readonly property var info: Weather.describe(modelData.code)

                            width: (days.width - days.spacing * 4) / 5
                            implicitHeight: forecastColumn.implicitHeight + Theme.spacing.sm * 2
                            radius: Theme.radius.medium
                            color: index === 0 ? Colors.secondaryContainer : Colors.surfaceContainerHigh

                            Column {
                                id: forecastColumn
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecast.index === 0 ? "Today" : forecast.modelData.date.toLocaleString(Qt.locale("en_US"), "ddd")
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.small
                                    font.weight: Font.DemiBold
                                    color: forecast.index === 0 ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecast.info.icon
                                    font.family: Theme.font.icons
                                    font.pixelSize: Theme.calendar.forecastIconSize
                                    color: forecast.index === 0 ? Colors.textOnSecondaryContainer : Colors.primary
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecast.modelData.max + "°"
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.small
                                    font.weight: Font.DemiBold
                                    color: forecast.index === 0 ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecast.modelData.min + "°"
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.small
                                    color: forecast.index === 0 ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
                                    opacity: 0.8
                                }
                            }
                        }
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
