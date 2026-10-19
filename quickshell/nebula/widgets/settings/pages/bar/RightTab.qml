import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: Theme.settings.heroHeight * 0.7
        radius: Theme.radius.large
        color: Colors.primaryContainer

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.xs

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Time.time
                font.family: Theme.font.family
                font.pixelSize: Theme.settings.titleSize * 2
                font.weight: Font.Bold
                color: Colors.textOnPrimaryContainer
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Time.date
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                color: Colors.textOnPrimaryContainer
                opacity: 0.75
            }
        }
    }

    SettingGroup {
        title: "Clock"

        SettingRow {
            icon: "schedule"
            title: "24-hour clock"
            subtitle: Time.use24h ? "13:08" : "1:08 PM"
            clickable: true
            onClicked: Settings.clock.use24h = !Time.use24h

            Switch {
                checked: Time.use24h
                onToggled: Settings.clock.use24h = !Time.use24h
            }
        }
    }

    SettingGroup {
        title: "Buttons"

        SettingRow {
            icon: "keyboard_arrow_up"
            title: "Tray button"
            clickable: true
            onClicked: Settings.bar.trayButton = !Settings.bar.trayButton

            Switch {
                checked: Settings.bar.trayButton
                onToggled: Settings.bar.trayButton = !Settings.bar.trayButton
            }
        }

        SettingRow {
            visible: Battery.available
            icon: "battery_horiz_075"
            title: "Battery ring"
            clickable: true
            onClicked: Settings.bar.batteryRing = !Settings.bar.batteryRing

            Switch {
                checked: Settings.bar.batteryRing
                onToggled: Settings.bar.batteryRing = !Settings.bar.batteryRing
            }
        }
    }

    SettingGroup {
        title: "Weather"

        SettingRow {
            icon: "location_on"
            title: "City"
            subtitle: Weather.error !== "" ? Weather.error
                    : Weather.place !== "" ? "Showing " + Weather.place
                    : "Shows the weather under the calendar"

            TextField {
                text: Settings.weather.city
                placeholder: "Amsterdam"
                onEdited: text => Settings.weather.city = text.trim()
            }
        }
    }

    SettingGroup {
        title: "Quick settings"

        SettingRow {
            icon: "grid_view"
            title: "Tiles"
            subtitle: "Drag tiles to add, reorder or remove them"
        }

        Item {
            id: board

            readonly property real pad: Theme.spacing.md
            readonly property real gap: Theme.spacing.sm
            readonly property real cellW: (width - pad * 2 - gap) / 2
            readonly property real cellH: Theme.button.size + Theme.spacing.sm * 2
            readonly property real labelH: Theme.font.normal + Theme.spacing.lg

            property string dragKey: ""
            property bool fromGrid: false
            property point pointer: Qt.point(0, 0)

            readonly property bool cancelled: pointer.x < -cellW / 2 || pointer.x > width + cellW / 2 || pointer.y < -cellH / 2
            readonly property real gridEdge: pad + rowsHeight(Tiles.keys.length + 1) + (fromGrid ? gap : cellH / 2)
            readonly property bool overGrid: !cancelled && pointer.y < gridEdge
            readonly property bool toPool: dragKey !== "" && !preview.includes(dragKey)

            readonly property var preview: {
                const keys = Tiles.keys;
                if (dragKey === "") return keys;
                if (cancelled) return keys;
                const base = keys.filter(k => k !== dragKey);
                if (!overGrid) return base;
                const col = Math.max(0, Math.min(1, Math.floor((pointer.x - pad) / (cellW + gap))));
                const row = Math.max(0, Math.floor((pointer.y - pad) / (cellH + gap)));
                base.splice(Math.min(row * 2 + col, base.length), 0, dragKey);
                return base;
            }
            readonly property var pool: Tiles.all.map(t => t.key).filter(k => Tiles.available(k) && !preview.includes(k))

            readonly property real labelY: pad + rowsHeight(preview.length + 1) + Theme.spacing.lg
            readonly property real poolTop: labelY + labelH
            readonly property real poolHeight: rowsHeight(Math.max(2, pool.length))

            function rowsHeight(n) {
                return Math.ceil(n / 2) * (cellH + gap) - gap;
            }

            function slot(index, top) {
                return Qt.point(pad + (index % 2) * (cellW + gap), top + Math.floor(index / 2) * (cellH + gap));
            }

            function drop() {
                Tiles.save(preview);
                dragKey = "";
            }

            Layout.fillWidth: true
            implicitHeight: poolTop + poolHeight + pad

            Behavior on implicitHeight {
                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
            }

            Row {
                y: board.labelY
                x: board.pad + Theme.spacing.xs
                height: board.labelH
                spacing: Theme.spacing.sm

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Available"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    font.weight: Font.DemiBold
                    color: Colors.textOnSurface
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: board.dragKey !== "" && board.fromGrid ? "drop here to remove" : "drag one up to add it"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    color: board.toPool && board.fromGrid ? Colors.primary : Colors.textOnSurfaceVariant

                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.fast }
                    }
                }
            }

            Rectangle {
                readonly property bool target: board.toPool && board.fromGrid

                x: board.pad - board.gap
                y: board.poolTop - board.gap
                width: board.width - (board.pad - board.gap) * 2
                height: board.poolHeight + board.gap * 2
                radius: Theme.radius.large + board.gap
                visible: target || board.pool.length === 0
                color: target ? Qt.alpha(Colors.primary, 0.08) : "transparent"
                border.width: target ? 2 : 1
                border.color: target ? Colors.primary : Colors.outlineVariant

                Behavior on color {
                    ColorAnimation { duration: Theme.anim.fast }
                }

                Text {
                    anchors.centerIn: parent
                    visible: board.pool.length === 0
                    text: "Every tile is in use"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Colors.textOnSurfaceVariant
                }
            }

            Rectangle {
                readonly property int gridIndex: board.preview.indexOf(board.dragKey)
                readonly property point at: gridIndex >= 0 ? board.slot(gridIndex, board.pad)
                                          : board.slot(Math.max(0, board.pool.indexOf(board.dragKey)), board.poolTop)

                visible: board.dragKey !== ""
                x: at.x
                y: at.y
                width: board.cellW
                height: board.cellH
                radius: Theme.radius.large
                color: Qt.alpha(Colors.primary, 0.12)
                border.width: 2
                border.color: Colors.primary

                Behavior on x {
                    NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                }

                Behavior on y {
                    NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                }
            }

            Rectangle {
                readonly property point at: board.slot(board.preview.length, board.pad)

                x: at.x
                y: at.y
                width: board.cellW
                height: board.cellH
                radius: Theme.radius.large
                color: Colors.surfaceContainerHighest
                opacity: 0.6

                Behavior on x {
                    NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                }

                Behavior on y {
                    NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.lg
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.md

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "settings"
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: Colors.textOnSurface
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Settings"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        color: Colors.textOnSurface
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.lg
                    anchors.verticalCenter: parent.verticalCenter
                    text: "lock"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.textOnSurfaceVariant
                }
            }

            Repeater {
                model: Tiles.all

                Rectangle {
                    id: tile

                    required property var modelData
                    readonly property string key: modelData.key
                    readonly property bool held: board.dragKey === key
                    readonly property int gridIndex: board.preview.indexOf(key)
                    readonly property int poolIndex: board.pool.indexOf(key)
                    readonly property bool inGrid: gridIndex >= 0
                    readonly property point home: inGrid ? board.slot(gridIndex, board.pad) : board.slot(Math.max(0, poolIndex), board.poolTop)
                    readonly property bool hovered: dragArea.containsMouse && board.dragKey === ""
                    readonly property color ink: held ? Colors.textOnPrimaryContainer
                                               : inGrid ? Colors.textOnSecondaryContainer
                                               : Colors.textOnSurface
                    property real dragX: 0
                    property real dragY: 0

                    visible: inGrid || poolIndex >= 0 || held
                    x: held ? dragX : home.x
                    y: held ? dragY : home.y
                    z: held ? 10 : 1
                    width: board.cellW
                    height: board.cellH
                    radius: Theme.radius.large
                    scale: held ? 1.05 : hovered ? 1.02 : 1
                    rotation: held ? 2 : 0
                    color: held ? Colors.primaryContainer
                         : inGrid ? Colors.secondaryContainer
                         : Colors.surfaceContainer
                    border.width: inGrid || held ? 0 : 1
                    border.color: Colors.outlineVariant

                    Behavior on x {
                        enabled: !tile.held
                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                    }

                    Behavior on y {
                        enabled: !tile.held
                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                    }

                    Behavior on scale {
                        NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                    }

                    Behavior on rotation {
                        NumberAnimation { duration: Theme.anim.fast }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.fast }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: tile.ink
                        opacity: tile.hovered ? 0.08 : 0
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.lg
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacing.md

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: tile.modelData.icon
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: tile.inGrid || tile.held ? tile.ink : Colors.primary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: tile.modelData.title
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            color: tile.ink
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter
                        text: "drag_indicator"
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: tile.ink
                        opacity: tile.held || tile.hovered ? 1 : 0.45

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.anim.fast }
                        }
                    }

                    MouseArea {
                        id: dragArea

                        property point grab: Qt.point(0, 0)

                        anchors.fill: parent
                        hoverEnabled: true
                        preventStealing: true
                        cursorShape: tile.held ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                        onPressed: mouse => {
                            grab = Qt.point(mouse.x, mouse.y);
                            tile.dragX = tile.x;
                            tile.dragY = tile.y;
                            board.fromGrid = tile.inGrid;
                            board.pointer = mapToItem(board, mouse.x, mouse.y);
                            board.dragKey = tile.key;
                        }

                        onPositionChanged: mouse => {
                            if (!pressed) return;
                            const p = mapToItem(board, mouse.x, mouse.y);
                            tile.dragX = p.x - grab.x;
                            tile.dragY = p.y - grab.y;
                            board.pointer = p;
                        }

                        onReleased: board.drop()
                        onCanceled: board.dragKey = ""
                    }
                }
            }
        }
    }
}
