import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: page

    property int tab: 0

    spacing: Theme.spacing.xl

    SegmentedButton {
        Layout.fillWidth: true
        options: ["Left", "Middle", "Right"]
        currentIndex: page.tab
        onSelected: index => page.tab = index
    }

    Loader {
        id: tabLoader
        Layout.fillWidth: true
        sourceComponent: [leftTab, middleTab, rightTab][page.tab]
        onLoaded: tabFade.restart()

        NumberAnimation {
            id: tabFade
            target: tabLoader
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    Component {
        id: leftTab

        ColumnLayout {
            spacing: Theme.spacing.xl

            SettingGroup {
                title: "Workspaces"

                SettingRow {
                    icon: "view_week"
                    title: "Workspaces per group"
                    subtitle: "Dots before a new group starts"

                    Slider {
                        width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        from: 3
                        to: 10
                        stepSize: 1
                        value: Settings.bar.workspaces
                        onMoved: Settings.bar.workspaces = Math.round(value)
                    }

                    NumberField {
                        anchors.verticalCenter: parent.verticalCenter
                        value: Settings.bar.workspaces
                        from: 3
                        to: 10
                        step: 1
                        factor: 1
                        decimals: 0
                        suffix: ""
                        onEdited: value => Settings.bar.workspaces = value
                    }
                }
            }
        }
    }

    Component {
        id: middleTab

        ColumnLayout {
            spacing: Theme.spacing.xl

            SettingGroup {
                title: "Media"

                SettingRow {
                    icon: "graphic_eq"
                    title: "Visualizer"
                    subtitle: "The cava bar!"
                    clickable: true
                    onClicked: Settings.bar.visualizer = !Settings.bar.visualizer

                    Switch {
                        checked: Settings.bar.visualizer
                        onToggled: Settings.bar.visualizer = !Settings.bar.visualizer
                    }
                }

                SettingRow {
                    icon: "lyrics"
                    title: "Synced lyrics"
                    subtitle: "In the sized media card  "
                    clickable: true
                    onClicked: Settings.bar.lyrics = !Settings.bar.lyrics

                    Switch {
                        checked: Settings.bar.lyrics
                        onToggled: Settings.bar.lyrics = !Settings.bar.lyrics
                    }
                }
            }

            SettingGroup {
                title: "Island"

                SettingRow {
                    icon: "timer"
                    title: "Volume and brightness popup"

                    Slider {
                        width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        from: 500
                        to: 4000
                        stepSize: 250
                        value: Settings.bar.osdDuration
                        onMoved: Settings.bar.osdDuration = Math.round(value / 250) * 250
                    }

                    NumberField {
                        anchors.verticalCenter: parent.verticalCenter
                        value: Settings.bar.osdDuration
                        from: 500
                        to: 4000
                        step: 250
                        factor: 1000
                        decimals: 2
                        suffix: " s"
                        onEdited: value => Settings.bar.osdDuration = value
                    }
                }

                SettingRow {
                    icon: "deployed_code"
                    title: "Logo when idle"
                    clickable: true
                    onClicked: Settings.bar.osLogo = !Settings.bar.osLogo

                    Switch {
                        checked: Settings.bar.osLogo
                        onToggled: Settings.bar.osLogo = !Settings.bar.osLogo
                    }
                }
            }
        }
    }

    Component {
        id: rightTab

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
        }
    }
}
