import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: root

    signal navigate(string target)

    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Widgets"

        Grid {
            id: grid

            readonly property real cell: (width - spacing * (columns - 1)) / columns

            Layout.fillWidth: true
            Layout.margins: Theme.spacing.md
            columns: 3
            spacing: Theme.spacing.md

            Repeater {
                model: Widgets.ids

                Rectangle {
                    id: card

                    required property string modelData
                    readonly property var cfg: Widgets.get(modelData) ?? ({})
                    readonly property var palette: Widgets.palette(cfg.color)
                    readonly property bool on: cfg.enabled === true

                    width: grid.cell
                    height: grid.cell * 1.05
                    radius: cardMouse.containsMouse ? Theme.radius.large + Theme.spacing.xs : Theme.radius.large
                    color: cardMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh

                    Behavior on radius {
                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.fast }
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.navigate("widget:" + card.modelData)
                    }

                    Item {
                        id: preview
                        anchors.top: parent.top
                        anchors.topMargin: Theme.spacing.lg
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: grid.cell * 0.55
                        height: width
                        opacity: card.on ? 1 : 0.4

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.anim.medium }
                        }

                        MaterialShape {
                            anchors.fill: parent
                            visible: card.cfg.type !== "image"
                            shape: MaterialShape[card.cfg.shape ?? "Circle"] ?? MaterialShape.Circle
                            color: card.palette.fill
                            animationDuration: Theme.anim.medium
                            animationEasing.type: Easing.BezierSpline
                            animationEasing.bezierCurve: Theme.anim.emphasizedDecel
                        }

                        ShapedArt {
                            anchors.fill: parent
                            visible: card.cfg.type === "image"
                            shape: MaterialShape[card.cfg.shape ?? "Clover4Leaf"] ?? MaterialShape.Clover4Leaf
                            color: card.palette.fill
                            source: card.cfg.type === "image" && card.cfg.source ? Wallpaper.url(card.cfg.source) : ""
                            sourceSize: Qt.size(width * 2, height * 2)
                            animationDuration: Theme.anim.medium
                            animationEasing.type: Easing.BezierSpline
                            animationEasing.bezierCurve: Theme.anim.emphasizedDecel
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: card.cfg.type !== "image"
                            text: Widgets.types[card.cfg.type]?.icon ?? "widgets"
                            font.family: Theme.font.icons
                            font.pixelSize: parent.width * 0.4
                            color: card.palette.text
                        }
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: Theme.spacing.md
                        spacing: Theme.spacing.sm

                        Text {
                            Layout.fillWidth: true
                            text: Widgets.label(card.cfg)
                            elide: Text.ElideRight
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            font.weight: Font.DemiBold
                            color: Colors.textOnSurface
                        }

                        Switch {
                            checked: card.on
                            onToggled: Widgets.update(card.modelData, { enabled: !card.on })
                        }
                    }
                }
            }

            Rectangle {
                width: grid.cell
                height: grid.cell * 1.05
                radius: addMouse.containsMouse ? Theme.radius.large + Theme.spacing.xs : Theme.radius.large
                color: addMouse.containsMouse ? Qt.alpha(Colors.primary, 0.08) : "transparent"
                border.width: 2
                border.color: Colors.outlineVariant

                Behavior on radius {
                    NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacing.xs

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "add"
                        font.family: Theme.font.icons
                        font.pixelSize: grid.cell * 0.28
                        color: Colors.primary
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Add widget"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: Font.DemiBold
                        color: Colors.primary
                    }
                }

                MouseArea {
                    id: addMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.navigate("newwidget")
                }
            }
        }
    }
}
