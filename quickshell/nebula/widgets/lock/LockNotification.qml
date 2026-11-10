import QtQuick
import M3Shapes
import qs.components
import qs.theme

Item {
    id: root

    property string name: ""
    property int count: 1
    property string summary: ""
    property string icon: ""
    property real morph: 0
    property real unit: 1

    readonly property real fade: Math.max(0, Math.min(1, (morph - 0.35) / 0.3))
    readonly property real idleFade: 1 - Math.max(0, Math.min(1, morph * 3))
    readonly property real bubble: Theme.lock.bubbleSize * unit
    readonly property int tone: {
        let h = 0;
        for (let i = 0; i < name.length; i++) h = (h * 31 + name.charCodeAt(i)) % 997;
        return h % 3;
    }
    readonly property color toneFill: [Colors.secondary, Colors.tertiary, Colors.primary][tone]
    readonly property color toneText: [Colors.textOnSecondary, Colors.textOnTertiary, Colors.textOnPrimary][tone]
    readonly property string initial: name.length > 0 ? name.charAt(0).toUpperCase() : "?"

    Item {
        anchors.fill: parent
        opacity: root.idleFade
        visible: opacity > 0

        Rectangle {
            id: disc

            x: (parent.width - width) / 2
            width: root.bubble
            height: width
            radius: width / 2
            color: Qt.alpha(Colors.secondaryContainer, Theme.lock.surfaceTint)

            ShapedArt {
                id: idleArt

                anchors.centerIn: parent
                width: parent.width * 0.6
                height: width
                shape: MaterialShape.Cookie6Sided
                color: root.toneFill
                source: root.icon
                sourceSize: Qt.size(width * 2, height * 2)

                Text {
                    anchors.centerIn: parent
                    visible: !idleArt.hasImage
                    text: root.initial
                    font.family: Theme.font.family
                    font.pixelSize: parent.height * 0.5
                    font.weight: Font.DemiBold
                    color: root.toneText
                }
            }
        }

        Rectangle {
            visible: root.count > 1
            x: disc.x + disc.width - width * 0.8
            y: -height * 0.15
            width: Math.max(height, badge.implicitWidth + 12)
            height: 24
            radius: 12
            color: Colors.primary

            Text {
                id: badge

                anchors.centerIn: parent
                text: root.count
                font.family: Theme.font.family
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Colors.textOnPrimary
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.bubble + 8
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.name
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            color: Qt.alpha(Colors.textOnSurface, 0.75)
        }
    }

    Item {
        anchors.fill: parent
        opacity: root.fade
        visible: opacity > 0

        GlassRect {
            anchors.fill: parent
            radius: height / 2
            fill: Colors.secondaryContainer
            tint: Theme.lock.surfaceTint
            light: 0
        }

        ShapedArt {
            id: art

            x: parent.height * 0.16
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height * 0.68
            height: width
            shape: MaterialShape.Cookie6Sided
            color: root.toneFill
            source: root.icon
            sourceSize: Qt.size(width * 2, height * 2)

            Text {
                anchors.centerIn: parent
                visible: !art.hasImage
                text: root.initial
                font.family: Theme.font.family
                font.pixelSize: parent.height * 0.5
                font.weight: Font.DemiBold
                color: root.toneText
            }
        }

        Column {
            anchors.left: art.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.name + (root.count > 1 ? "  ·  " + root.count : "")
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                font.weight: Font.Medium
                color: Colors.textOnSecondaryContainer
            }

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.summary
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Qt.alpha(Colors.textOnSecondaryContainer, 0.7)
            }
        }
    }
}
