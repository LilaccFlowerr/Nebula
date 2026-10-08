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
        id: tilesGroup

        property int picking: -1

        title: "Quick settings"

        SettingRow {
            icon: "grid_view"
            title: "Tiles"
            subtitle: "Settings is always the last one"

            SegmentedButton {
                width: Theme.settings.controlWidth
                anchors.verticalCenter: parent.verticalCenter
                options: Tiles.counts.map(String)
                currentIndex: Tiles.counts.indexOf(Tiles.count)
                onSelected: index => {
                    tilesGroup.picking = -1;
                    Tiles.setCount(Tiles.counts[index]);
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.md
            columns: 2
            rowSpacing: Theme.spacing.sm
            columnSpacing: Theme.spacing.sm

            Repeater {
                model: Tiles.keys.concat(["settings"])

                Rectangle {
                    id: cell

                    required property string modelData
                    required property int index
                    readonly property bool fixed: modelData === "settings"
                    readonly property bool picked: tilesGroup.picking === index
                    readonly property var info: fixed ? { title: "Settings", icon: "settings" } : Tiles.info(modelData)

                    Layout.fillWidth: true
                    implicitHeight: Theme.button.size + Theme.spacing.sm * 2
                    radius: picked ? height / 2 : Theme.radius.large
                    color: picked ? Colors.secondaryContainer
                         : cellMouse.containsMouse && !fixed ? Colors.surfaceContainerHighest
                         : Colors.surfaceContainer
                    opacity: fixed ? 0.5 : 1

                    Behavior on radius {
                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.fast }
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.lg
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacing.md

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: cell.info?.icon ?? ""
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: cell.picked ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: cell.info?.title ?? ""
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            color: cell.picked ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }
                    }

                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        enabled: !cell.fixed
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: tilesGroup.picking = cell.picked ? -1 : cell.index
                    }
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacing.md
            Layout.rightMargin: Theme.spacing.md
            Layout.bottomMargin: Theme.spacing.md
            visible: tilesGroup.picking >= 0
            spacing: Theme.spacing.sm

            Repeater {
                model: Tiles.all

                Rectangle {
                    id: chip

                    required property var modelData
                    readonly property bool current: Tiles.keys[tilesGroup.picking] === modelData.key
                    readonly property bool used: Tiles.keys.includes(modelData.key)

                    visible: Tiles.available(modelData.key)
                    implicitWidth: chipRow.implicitWidth + Theme.spacing.lg * 2
                    implicitHeight: Theme.button.size
                    radius: current ? height / 2 : Theme.radius.medium
                    color: current ? Colors.secondaryContainer
                         : chipMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.08) : "transparent"
                    border.width: current ? 0 : 1
                    border.color: Colors.outlineVariant
                    opacity: used && !current ? 0.6 : 1

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: Theme.spacing.sm

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.modelData.icon
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: chip.current ? Colors.textOnSecondaryContainer : Colors.primary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.modelData.title
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            color: chip.current ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }
                    }

                    MouseArea {
                        id: chipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Tiles.setAt(tilesGroup.picking, chip.modelData.key);
                            tilesGroup.picking = -1;
                        }
                    }
                }
            }
        }
    }
}
