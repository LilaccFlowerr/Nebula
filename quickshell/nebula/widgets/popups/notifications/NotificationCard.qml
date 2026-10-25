import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    required property var n
    property bool open: hovered
    property real contentOpacity: 1
    readonly property bool hovered: hover.hovered

    readonly property bool urgent: Notifications.isUrgent(n)
    readonly property bool hasPhoto: n !== null && n.image !== "" && !n.image.startsWith("image://icon/")
    readonly property string iconSource: !n ? ""
        : n.image.startsWith("image://icon/") ? Quickshell.iconPath(n.image.slice(13), true)
        : Quickshell.iconPath(n.appIcon, true)
    readonly property color onFill: urgent ? Colors.textOnErrorContainer : Colors.textOnPrimaryContainer
    readonly property var actions: n ? n.actions.filter(a => a.identifier !== "default") : []

    implicitWidth: Theme.toast.width
    implicitHeight: layout.implicitHeight + Theme.spacing.lg * 2

    HoverHandler {
        id: hover
    }

    GlassRect {
        anchors.fill: parent
        radius: Theme.toast.radius
        light: 0
        fill: root.urgent ? Colors.errorContainer : Colors.primaryContainer
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifications.activate(root.n)
    }

    RowLayout {
        id: layout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md
        opacity: root.contentOpacity
        visible: opacity > 0

        Item {
            Layout.alignment: Qt.AlignTop
            implicitWidth: Theme.toast.iconSize
            implicitHeight: Theme.toast.iconSize

            MaterialShape {
                anchors.fill: parent
                implicitSize: parent.width
                visible: !root.hasPhoto
                shape: MaterialShape.Cookie9Sided
                color: root.urgent ? Colors.errorColor : Colors.primary
            }

            ShapedArt {
                anchors.fill: parent
                visible: root.hasPhoto
                shape: MaterialShape.Cookie9Sided
                color: Colors.primaryContainer
                source: root.hasPhoto ? root.n.image : ""
                sourceSize: Qt.size(Theme.toast.iconSize * 2, Theme.toast.iconSize * 2)
            }

            IconImage {
                anchors.centerIn: parent
                visible: !root.hasPhoto && root.iconSource !== ""
                implicitSize: Theme.button.iconSize + 4
                source: root.iconSource
            }

            Text {
                anchors.centerIn: parent
                visible: !root.hasPhoto && root.iconSource === ""
                text: root.urgent ? "priority_high" : "notifications"
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize + 4
                color: root.urgent ? Colors.textOnError : Colors.textOnPrimary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xs

                Text {
                    Layout.fillWidth: true
                    text: root.n ? root.n.appName : ""
                    elide: Text.ElideRight
                    color: root.onFill
                    opacity: 0.75
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    font.weight: Font.DemiBold
                }

                IconButton {
                    implicitWidth: 26
                    implicitHeight: 26
                    icon: "close"
                    onClicked: Notifications.dismiss(root.n)
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.n ? root.n.summary : ""
                elide: Text.ElideRight
                color: root.onFill
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.n ? root.n.body : ""
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: root.open ? Theme.bar.notificationMaxLines : Theme.toast.bodyLines
                elide: Text.ElideRight
                color: root.onFill
                opacity: 0.8
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.sm
                visible: root.open && root.actions.length > 0
                spacing: Theme.spacing.sm

                Repeater {
                    model: root.actions

                    Rectangle {
                        required property var modelData
                        required property int index

                        implicitWidth: actionText.implicitWidth + Theme.spacing.lg * 2
                        implicitHeight: 34
                        radius: height / 2
                        color: index === 0 ? (actionMouse.containsMouse ? Qt.lighter(Colors.primary, 1.1) : Colors.primary)
                             : Qt.alpha(root.onFill, actionMouse.containsMouse ? 0.18 : 0.1)

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.text
                            color: index === 0 ? Colors.textOnPrimary : root.onFill
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const n = root.n;
                                modelData.invoke();
                                Notifications.dismiss(n);
                            }
                        }
                    }
                }
            }
        }
    }
}
