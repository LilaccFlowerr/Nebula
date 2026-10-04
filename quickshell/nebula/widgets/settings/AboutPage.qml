import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    spacing: Theme.spacing.xl

    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing.lg
        spacing: Theme.spacing.md

        ShapedArt {
            id: avatar
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Theme.settings.avatarSize
            implicitHeight: Theme.settings.avatarSize
            shape: avatarMouse.containsMouse ? MaterialShape.Sunny : MaterialShape.Cookie9Sided
            source: SystemInfo.avatar
            color: Colors.primaryContainer
            animationDuration: Theme.anim.slow
            animationEasing.type: Easing.OutBack
            animationEasing.overshoot: Theme.anim.overshoot

            Text {
                anchors.centerIn: parent
                text: "add_a_photo"
                font.family: Theme.font.icons
                font.pixelSize: Theme.settings.titleSize
                color: Colors.textOnPrimaryContainer
                opacity: avatarMouse.containsMouse || !avatar.hasImage ? 0.9 : 0

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

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: SystemInfo.user + "@" + SystemInfo.host
            font.family: Theme.font.family
            font.pixelSize: Theme.settings.titleSize * 0.8
            font.weight: Font.DemiBold
            color: Colors.textOnSurface
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: SystemInfo.uptime
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: Colors.textOnSurfaceVariant
        }
    }

    SettingGroup {
        title: "System"

        SettingRow {
            title: "Operating system"
            subtitle: SystemInfo.osId

            Text {
                text: SystemInfo.osLogo
                font.family: Theme.font.logos
                font.pixelSize: Theme.settings.titleSize
                color: Colors.primary
            }
        }

        SettingRow {
            icon: "desktop_windows"
            title: "Compositor"
            subtitle: "Hyprland"
        }

        SettingRow {
            icon: "auto_awesome"
            title: "Shell"
            subtitle: "Nebula, built from scratch in Quickshell"
        }
    }
}
