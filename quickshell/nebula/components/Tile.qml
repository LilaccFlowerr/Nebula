import QtQuick
import QtQuick.Layouts
import qs.theme

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false

    signal clicked()

    implicitHeight: Theme.quickSettings.tileHeight

    property real outerRadius: active ? height / 2 : Theme.radius.large
    readonly property real innerRadius: Theme.quickSettings.tileInnerRadius
    readonly property color fill: active ? Colors.primaryContainer : Colors.surfaceContainerHigh
    readonly property color textColor: active ? Colors.textOnPrimaryContainer : Colors.textOnSurface

    Behavior on outerRadius {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Theme.quickSettings.tileGap

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: root.height
            topLeftRadius: root.outerRadius
            bottomLeftRadius: root.outerRadius
            topRightRadius: root.innerRadius
            bottomRightRadius: root.innerRadius
            color: iconMouse.pressed ? Qt.darker(root.fill, 1.1) : root.fill

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.quickSettings.tileIconSize
                color: root.textColor
            }

            MouseArea {
                id: iconMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clicked()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            topLeftRadius: root.innerRadius
            bottomLeftRadius: root.innerRadius
            topRightRadius: root.outerRadius
            bottomRightRadius: root.outerRadius
            color: textMouse.pressed ? Qt.darker(root.fill, 1.1) : root.fill

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - Theme.spacing.sm * 2
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    color: root.textColor
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }

                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: root.subtitle
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    color: root.textColor
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }
            }

            MouseArea {
                id: textMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clicked()
            }
        }
    }
}
