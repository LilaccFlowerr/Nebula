import QtQuick
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property string shapeName: "Sunny"
    property real baseSize: 180
    property string content: ""
    property string colorRole: "tertiary"
    property real textScale: 1
    readonly property var palette: Widgets.palette(colorRole)

    property real size: baseSize

    Behavior on size {
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    implicitWidth: size
    implicitHeight: size

    MaterialShape {
        anchors.fill: parent
        shape: MaterialShape[root.shapeName] ?? MaterialShape.Sunny
        color: root.palette.fill
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.OutBack
        animationEasing.overshoot: Theme.anim.overshoot
    }

    Text {
        anchors.centerIn: parent
        width: root.size * 0.62
        height: root.size * 0.5
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        fontSizeMode: Text.Fit
        minimumPixelSize: 8
        text: root.content === "" ? "Edit me" : root.content
        opacity: root.content === "" ? 0.5 : 1
        font.family: Theme.font.family
        font.pixelSize: root.size * 0.16 * root.textScale
        font.weight: Font.DemiBold
        color: root.palette.text
    }
}
