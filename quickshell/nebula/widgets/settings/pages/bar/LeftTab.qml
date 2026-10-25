import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    signal navigate(string target)

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

        SettingRow {
            icon: "category"
            title: "Style"
            subtitle: "What each workspace looks like"

            SegmentedButton {
                readonly property var styles: ["numbers", "pills", "shapes"]

                width: Theme.settings.controlWidth
                anchors.verticalCenter: parent.verticalCenter
                options: ["Numbers", "Pills", "Shapes"]
                currentIndex: Math.max(0, styles.indexOf(Settings.bar.workspaceStyle))
                onSelected: index => Settings.bar.workspaceStyle = styles[index]
            }
        }
    }

    SettingGroup {
        title: "Logo"

        SettingRow {
            icon: "deployed_code"
            title: "Show logo"
            subtitle: "Next to the workspaces"
            clickable: true
            onClicked: Settings.bar.osLogo = !Settings.bar.osLogo

            Switch {
                checked: Settings.bar.osLogo
                onToggled: Settings.bar.osLogo = !Settings.bar.osLogo
            }
        }

        SettingRow {
            icon: "category"
            title: "Logo"
            subtitle: "Where the logo comes from"
            visible: Settings.bar.osLogo

            SegmentedButton {
                readonly property var modes: ["os", "preset", "image", "text"]

                width: Theme.settings.controlWidth + Theme.settings.fieldWidth
                anchors.verticalCenter: parent.verticalCenter
                options: ["OS", "Preset", "Image", "Text"]
                currentIndex: Math.max(0, modes.indexOf(Settings.bar.logoMode))
                onSelected: index => Settings.bar.logoMode = modes[index]
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: presets.implicitHeight + Theme.spacing.lg * 2
            visible: Settings.bar.osLogo && Settings.bar.logoMode === "preset"

            Flow {
                id: presets
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Theme.spacing.lg + Theme.spacing.xs
                anchors.rightMargin: Theme.spacing.lg + Theme.spacing.xs
                spacing: Theme.spacing.xs

                Repeater {
                    model: SystemInfo.logoPresets

                    Rectangle {
                        required property var modelData
                        readonly property bool chosen: Settings.bar.logoPreset === modelData.key

                        width: Theme.settings.logoButton
                        height: width
                        radius: width / 2
                        color: chosen ? Colors.primaryContainer : presetMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: Theme.anim.fast }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.glyph
                            font.family: Theme.font.logos
                            font.pixelSize: Theme.button.iconSize
                            color: chosen ? Colors.textOnPrimaryContainer : Colors.textOnSurfaceVariant
                        }

                        MouseArea {
                            id: presetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Settings.bar.logoPreset = modelData.key
                        }
                    }
                }
            }
        }

        SettingRow {
            icon: "image"
            title: "Image"
            subtitle: Settings.bar.logoImage !== "" ? Wallpaper.name(Settings.bar.logoImage) : "Tinted in your accent color"
            visible: Settings.bar.osLogo && Settings.bar.logoMode === "image"

            ActionButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "photo_library"
                text: Settings.bar.logoImage !== "" ? "Change" : "Choose"
                filled: true
                onClicked: {
                    GlobalStates.pickFor = "logo";
                    page.navigate("images");
                }
            }
        }

        SettingRow {
            icon: "text_fields"
            title: "Text"
            subtitle: "A few letters or an emoji"
            visible: Settings.bar.osLogo && Settings.bar.logoMode === "text"

            TextField {
                anchors.verticalCenter: parent.verticalCenter
                text: Settings.bar.logoText
                placeholder: "nebula"
                onEdited: text => Settings.bar.logoText = text
            }
        }
    }
}
