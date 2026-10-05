import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacing.lg
        spacing: Theme.spacing.md

        ShapedArt {
            id: avatar

            readonly property var hoverShapes: [
                MaterialShape.Sunny, MaterialShape.VerySunny, MaterialShape.Flower, MaterialShape.Puffy,
                MaterialShape.Clover4Leaf, MaterialShape.Clover8Leaf, MaterialShape.Cookie4Sided, MaterialShape.Cookie6Sided,
                MaterialShape.Cookie12Sided, MaterialShape.SoftBurst, MaterialShape.Pentagon, MaterialShape.Gem,
                MaterialShape.Heart, MaterialShape.Ghostish
            ]
            property int hoverShape: MaterialShape.Sunny
            property bool shownHover: false

            function sync() {
                if (morphLock.running || shownHover === avatarMouse.containsMouse) return;
                if (avatarMouse.containsMouse) shuffle();
                shownHover = avatarMouse.containsMouse;
                morphLock.restart();
            }

            function shuffle() {
                let next = hoverShape;
                while (next === hoverShape) next = hoverShapes[Math.floor(Math.random() * hoverShapes.length)];
                hoverShape = next;
            }
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Theme.settings.avatarSize
            implicitHeight: Theme.settings.avatarSize
            shape: shownHover ? hoverShape : MaterialShape.Cookie9Sided
            source: SystemInfo.avatar
            color: Colors.primaryContainer
            animationDuration: Theme.anim.medium
            animationEasing.type: Easing.BezierSpline
            animationEasing.bezierCurve: Theme.anim.emphasizedDecel

            Timer {
                id: morphLock
                interval: avatar.animationDuration
                onTriggered: avatar.sync()
            }

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
                onContainsMouseChanged: avatar.sync()
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
            subtitle: "Nebula Shell - made by Ize <3"
        }
    }

    SettingGroup {
        title: "Made by"

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.lg
            spacing: Theme.spacing.lg

            Image {
                id: localAvatar
                visible: false
                source: Qt.resolvedUrl("../../../assets/author.png")
            }

            ShapedArt {
                implicitWidth: Theme.settings.authorSize
                implicitHeight: Theme.settings.authorSize
                shape: MaterialShape.Clover8Leaf
                color: Colors.primaryContainer
                source: localAvatar.status === Image.Ready ? localAvatar.source : "https://github.com/" + Theme.settings.github + ".png?size=256"
                sourceSize: Qt.size(width * 2, height * 2)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "Ize"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large + 4
                    font.weight: Font.Bold
                    color: Colors.textOnSurface
                }

                Text {
                    text: "@" + Theme.settings.github
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Colors.textOnSurfaceVariant
                }
            }

            ActionButton {
                icon: "code"
                text: "Nebula"
                onClicked: Qt.openUrlExternally("https://github.com/" + Theme.settings.github + "/Nebula")
            }

            ActionButton {
                icon: "open_in_new"
                text: "GitHub"
                filled: true
                onClicked: Qt.openUrlExternally("https://github.com/" + Theme.settings.github)
            }
        }
    }

    SettingGroup {
        title: "Reset"

        SettingRow {
            icon: "restart_alt"
            title: "Reset all settings"
            subtitle: "Your wallpaper and screens stay as they are"

            ActionButton {
                id: resetAll

                property bool armed: false

                icon: "restart_alt"
                text: armed ? "Click again" : "Reset all"
                danger: true
                filled: armed
                onClicked: {
                    if (armed) {
                        Settings.resetAll();
                        armed = false;
                    } else {
                        armed = true;
                        disarm.restart();
                    }
                }

                Timer {
                    id: disarm
                    interval: 3000
                    onTriggered: resetAll.armed = false
                }
            }
        }
    }
}
