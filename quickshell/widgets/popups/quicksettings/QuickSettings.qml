import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

Rectangle {
    id: root

    property bool open: false
    signal requestClose()

    implicitWidth: 360
    implicitHeight: column.implicitHeight + Theme.spacing.lg * 2
    radius: Theme.radius.large
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.9
    transformOrigin: Item.Top

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
        spacing: Theme.spacing.lg

        RowLayout {
            spacing: Theme.spacing.md

            ShapedImage {
                implicitWidth: 56
                implicitHeight: 56
                source: SystemInfo.avatar
                placeholderColor: Colors.surfaceContainerHigh

                Text {
                    anchors.centerIn: parent
                    text: "add_a_photo"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.button.iconSize
                    color: Colors.textOnSurface
                    opacity: avatarMouse.containsMouse ? 0.9 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.anim.fast }
                    }
                }

                MouseArea {
                    id: avatarMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemInfo.pickAvatar()
                }
            }

            ColumnLayout {
                spacing: 2

                Text {
                    text: SystemInfo.user + "@" + SystemInfo.host
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                }

                Text {
                    text: SystemInfo.uptime + (Battery.available ? " · " + Battery.percent + "%" : "")
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                }
            }
        }

        RowLayout {
            spacing: Theme.spacing.md

            Text {
                text: Audio.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: Colors.textOnSurface
            }

            Slider {
                Layout.fillWidth: true
                value: Audio.volume
                onMoved: Audio.setVolume(value)
            }
        }

        RowLayout {
            visible: Brightness.available
            spacing: Theme.spacing.md

            Text {
                text: "brightness_medium"
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: Colors.textOnSurface
            }

            Slider {
                Layout.fillWidth: true
                value: Brightness.level
                onMoved: Brightness.setBrightness(value)
            }
        }
    }
}
