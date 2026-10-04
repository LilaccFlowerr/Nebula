import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Keyboard"

        SettingRow {
            icon: "keyboard"
            title: "Layout"
            subtitle: "Comma separated, like us,nl"

            TextField {
                text: Settings.input.layout
                placeholder: "us"
                onEdited: text => Settings.input.layout = text || "us"
            }
        }

        SettingRow {
            icon: "keyboard_double_arrow_right"
            title: "Repeat rate"
            subtitle: "Characters per second while holding a key"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 10
                to: 60
                stepSize: 1
                value: Settings.input.repeatRate
                onMoved: Settings.input.repeatRate = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.input.repeatRate
                from: 10
                to: 60
                onEdited: value => Settings.input.repeatRate = value
            }
        }

        SettingRow {
            icon: "hourglass_top"
            title: "Repeat delay"
            subtitle: "How long to hold before it starts repeating"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 150
                to: 1000
                stepSize: 50
                value: Settings.input.repeatDelay
                onMoved: Settings.input.repeatDelay = Math.round(value / 50) * 50
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.input.repeatDelay
                from: 150
                to: 1000
                step: 50
                suffix: " ms"
                onEdited: value => Settings.input.repeatDelay = value
            }
        }
    }

    SettingGroup {
        title: "Mouse"

        SettingRow {
            icon: "mouse"
            title: "Speed"
            subtitle: "0 is the default"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: -1
                to: 1
                value: Settings.input.sensitivity
                onMoved: Settings.input.sensitivity = Math.round(value * 20) / 20
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.input.sensitivity
                from: -1
                to: 1
                step: 0.05
                decimals: 2
                onEdited: value => Settings.input.sensitivity = value
            }
        }

        SettingRow {
            icon: "trending_flat"
            title: "Flat acceleration"
            subtitle: "Same speed no matter how fast you move, nice for games"
            clickable: true
            onClicked: Settings.input.flatAccel = !Settings.input.flatAccel

            Switch {
                checked: Settings.input.flatAccel
                onToggled: Settings.input.flatAccel = !Settings.input.flatAccel
            }
        }
    }

    SettingGroup {
        title: "Touchpad"

        SettingRow {
            icon: "swipe_vertical"
            title: "Natural scrolling"
            subtitle: "Content moves with your fingers"
            clickable: true
            onClicked: Settings.input.naturalScroll = !Settings.input.naturalScroll

            Switch {
                checked: Settings.input.naturalScroll
                onToggled: Settings.input.naturalScroll = !Settings.input.naturalScroll
            }
        }

        SettingRow {
            icon: "touch_app"
            title: "Tap to click"
            subtitle: "A light tap counts as a click"
            clickable: true
            onClicked: Settings.input.tapToClick = !Settings.input.tapToClick

            Switch {
                checked: Settings.input.tapToClick
                onToggled: Settings.input.tapToClick = !Settings.input.tapToClick
            }
        }

        SettingRow {
            icon: "keyboard_hide"
            title: "Ignore while typing"
            subtitle: "Stops your palm from moving the cursor"
            clickable: true
            onClicked: Settings.input.disableWhileTyping = !Settings.input.disableWhileTyping

            Switch {
                checked: Settings.input.disableWhileTyping
                onToggled: Settings.input.disableWhileTyping = !Settings.input.disableWhileTyping
            }
        }
    }
}
