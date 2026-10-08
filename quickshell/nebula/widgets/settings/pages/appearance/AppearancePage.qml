import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: root

    signal navigate(string target)

    spacing: Theme.spacing.xl

    Component.onCompleted: Scheme.loadPreviews()

    ClippingRectangle {
        Layout.fillWidth: true
        implicitHeight: Theme.settings.heroHeight
        radius: Theme.radius.large
        color: Colors.surfaceContainerHigh

        Image {
            anchors.fill: parent
            source: Wallpaper.url(Wallpaper.current)
            sourceSize.width: width * 2
            sourceSize.height: height * 2
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spacing.lg
            implicitWidth: nameColumn.implicitWidth + Theme.spacing.lg * 2
            implicitHeight: nameColumn.implicitHeight + Theme.spacing.sm * 2
            radius: Theme.radius.medium
            color: Qt.alpha(Colors.surfaceContainerHigh, 0.9)

            ColumnLayout {
                id: nameColumn
                anchors.centerIn: parent
                spacing: 0

                Text {
                    text: "Wallpaper"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    color: Colors.textOnSurfaceVariant
                }

                Text {
                    text: Wallpaper.name(Wallpaper.current)
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                    color: Colors.textOnSurface
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spacing.lg
            implicitWidth: changeRow.implicitWidth + Theme.spacing.lg * 2
            implicitHeight: Theme.button.size
            radius: height / 2
            color: changeMouse.containsMouse ? Qt.lighter(Colors.primary, 1.1) : Colors.primary

            Row {
                id: changeRow
                anchors.centerIn: parent
                spacing: Theme.spacing.sm

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "wallpaper"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.button.iconSize
                    color: Colors.textOnPrimary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Change"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    font.weight: Font.DemiBold
                    color: Colors.textOnPrimary
                }
            }

            MouseArea {
                id: changeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.navigate("wallpapers")
            }
        }
    }

    SettingGroup {
        title: "Wallpaper transition"

        Flow {
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.md
            spacing: Theme.spacing.sm

            Repeater {
                model: Wallpaper.transitions

                Rectangle {
                    id: chip
                    required property var modelData
                    readonly property bool active: modelData.key === Wallpaper.transition.key
                    readonly property bool special: modelData.key === "random"
                    property int cycle: 0

                    implicitWidth: chipRow.implicitWidth + Theme.spacing.lg * 2
                    implicitHeight: Theme.button.size
                    radius: active ? height / 2 : Theme.radius.medium
                    color: special ? (active ? Colors.tertiary : Colors.tertiaryContainer)
                         : active ? Colors.secondaryContainer : chipMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.08) : "transparent"
                    border.width: active || special ? 0 : 1
                    border.color: Colors.outlineVariant

                    Timer {
                        running: chip.special && chip.visible
                        interval: Theme.anim.slow
                        repeat: true
                        onTriggered: chip.cycle = (chip.cycle + 1) % Wallpaper.shapes.length
                    }

                    Behavior on radius {
                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                    }

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: Theme.spacing.sm

                        MaterialShape {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: chip.modelData.shape >= 0 || chip.special
                            width: Theme.settings.iconSize
                            height: width
                            shape: chip.special ? Wallpaper.shapes[chip.cycle] : chip.modelData.shape >= 0 ? chip.modelData.shape : MaterialShape.Circle
                            animationDuration: Theme.anim.medium
                            animationEasing.type: Easing.BezierSpline
                            animationEasing.bezierCurve: Theme.anim.emphasizedDecel
                            color: chip.special ? (chip.active ? Colors.textOnTertiary : Colors.textOnTertiaryContainer)
                                 : chip.active ? Colors.textOnSecondaryContainer : Colors.primary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: chip.modelData.shape < 0 && !chip.special
                            text: chip.modelData.key === "random" ? "shuffle" : chip.modelData.key === "fade" ? "gradient" : "block"
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: chip.active ? Colors.textOnSecondaryContainer : Colors.primary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.modelData.name
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            font.weight: chip.active || chip.special ? Font.DemiBold : Font.Normal
                            color: chip.special ? (chip.active ? Colors.textOnTertiary : Colors.textOnTertiaryContainer)
                                 : chip.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }
                    }

                    MouseArea {
                        id: chipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Settings.wallpaper.transition = chip.modelData.key;
                            Wallpaper.replay();
                        }
                    }
                }
            }
        }
    }

    SettingGroup {
        title: "Color style"

        GridLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.md
            columns: 4
            rowSpacing: Theme.spacing.md
            columnSpacing: Theme.spacing.sm

            Repeater {
                model: Scheme.schemes

                Item {
                    id: option
                    required property var modelData
                    readonly property bool active: modelData.scheme === Scheme.current
                    readonly property var preview: Scheme.previews[modelData.scheme] ?? null

                    Layout.fillWidth: true
                    implicitHeight: optionColumn.implicitHeight + Theme.spacing.sm * 2

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radius.medium
                        color: option.active ? Colors.secondaryContainer : optionMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.06) : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: Theme.anim.fast }
                        }
                    }

                    ColumnLayout {
                        id: optionColumn
                        anchors.centerIn: parent
                        spacing: Theme.spacing.sm

                        MaterialShape {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: Theme.settings.swatchSize
                            implicitHeight: Theme.settings.swatchSize
                            shape: option.active ? MaterialShape.Cookie9Sided : MaterialShape.Circle
                            color: option.preview?.primary ?? Colors.surfaceContainerHighest
                            animationDuration: Theme.anim.slow
                            animationEasing.type: Easing.OutBack
                            animationEasing.overshoot: Theme.anim.overshoot

                            Behavior on color {
                                ColorAnimation { duration: Theme.anim.medium }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "check"
                                font.family: Theme.font.icons
                                font.pixelSize: Theme.settings.iconSize
                                color: Colors.surface
                                scale: option.active ? 1 : 0

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Theme.anim.medium
                                        easing.type: Easing.OutBack
                                        easing.overshoot: Theme.anim.overshoot
                                    }
                                }
                            }

                            LoadingIndicator {
                                anchors.centerIn: parent
                                width: parent.width * 0.7
                                height: width
                                contained: false
                                color: Colors.textOnSurfaceVariant
                                running: option.preview === null
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: option.modelData.name
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            font.weight: option.active ? Font.DemiBold : Font.Normal
                            color: option.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }
                    }

                    MouseArea {
                        id: optionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Scheme.set(option.modelData.scheme)
                    }
                }
            }
        }
    }

    SettingGroup {
        title: "Mode"

        SettingRow {
            icon: Scheme.dark ? "dark_mode" : "light_mode"
            title: "Dark mode"
            clickable: true
            onClicked: Scheme.toggleMode()

            Switch {
                checked: Scheme.dark
                onToggled: Scheme.toggleMode()
            }
        }
    }

    SettingGroup {
        title: "Motion"

        SettingRow {
            icon: "speed"
            title: "Animation speed"
            subtitle: "Higher is faster"
            enabled: !Settings.theme.reduceMotion
            opacity: enabled ? 1 : 0.4

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 0.5
                to: 2
                stepSize: 0.25
                value: Settings.theme.animSpeed
                onMoved: Settings.theme.animSpeed = Math.round(value * 4) / 4
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.theme.animSpeed
                from: 0.5
                to: 2
                step: 0.25
                factor: 1
                decimals: 2
                suffix: "×"
                onEdited: value => Settings.theme.animSpeed = value
            }
        }

        SettingRow {
            icon: "motion_photos_off"
            title: "Reduce motion"
            subtitle: "No animations, things just appear"
            clickable: true
            onClicked: Settings.theme.reduceMotion = !Settings.theme.reduceMotion

            Switch {
                checked: Settings.theme.reduceMotion
                onToggled: Settings.theme.reduceMotion = !Settings.theme.reduceMotion
            }
        }
    }
}
