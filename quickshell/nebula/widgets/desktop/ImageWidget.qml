import QtQuick
import M3Shapes
import qs.components
import qs.services
import qs.theme

ShapedArt {
    id: root

    property string shapeName: "Clover4Leaf"
    property real baseSize: 200
    property string path: ""
    property string colorRole: "secondary"

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
    shape: MaterialShape[shapeName] ?? MaterialShape.Clover4Leaf
    color: hasImage ? "transparent" : Widgets.palette(colorRole).fill
    source: path === "" ? "" : Wallpaper.url(path)
    sourceSize: Qt.size(1200, 1200)
    animationDuration: Theme.anim.slow
    animationEasing.type: Easing.OutBack
    animationEasing.overshoot: Theme.anim.overshoot
}
