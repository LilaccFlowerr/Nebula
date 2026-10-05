import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    signal navigate(string target)

    spacing: Theme.spacing.xl

    SettingGroup {
        Grid {
            id: grid

            readonly property real cell: (width - spacing * (columns - 1)) / columns

            Layout.fillWidth: true
            Layout.margins: Theme.spacing.md
            columns: 3
            spacing: Theme.spacing.md

            Repeater {
                model: Wallpaper.files

                ColumnLayout {
                    id: wall
                    required property string modelData
                    readonly property bool active: modelData === Wallpaper.current

                    width: grid.cell
                    spacing: Theme.spacing.xs

                    ClippingRectangle {
                        Layout.preferredWidth: grid.cell
                        Layout.preferredHeight: grid.cell * 10 / 16
                        radius: wall.active ? Theme.radius.large : Theme.radius.medium
                        color: Colors.surfaceContainerHighest
                        border.width: wall.active ? 3 : 0
                        border.color: Colors.primary

                        Behavior on radius {
                            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                        }

                        Image {
                            id: thumb
                            anchors.fill: parent
                            source: Wallpaper.url(wall.modelData)
                            sourceSize.width: Theme.settings.thumbWidth
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            scale: thumbMouse.containsMouse ? 1.05 : 1

                            Behavior on scale {
                                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                            }
                        }

                        LoadingIndicator {
                            anchors.centerIn: parent
                            width: parent.height * 0.4
                            height: width
                            running: thumb.status === Image.Loading
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: Theme.spacing.sm
                            width: Theme.settings.iconSize + Theme.spacing.xs * 2
                            height: width
                            radius: width / 2
                            color: Colors.primary
                            scale: wall.active ? 1 : 0

                            Behavior on scale {
                                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "check"
                                font.family: Theme.font.icons
                                font.pixelSize: Theme.settings.iconSize * 0.8
                                color: Colors.textOnPrimary
                            }
                        }

                        MouseArea {
                            id: thumbMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Wallpaper.set(wall.modelData);
                                page.navigate("");
                            }
                        }
                    }

                    Text {
                        Layout.preferredWidth: grid.cell
                        text: Wallpaper.name(wall.modelData)
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        font.weight: wall.active ? Font.DemiBold : Font.Normal
                        color: wall.active ? Colors.primary : Colors.textOnSurfaceVariant
                    }
                }
            }
        }
    }
}
