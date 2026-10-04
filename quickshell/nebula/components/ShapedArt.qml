import QtQuick
import QtQuick.Effects
import M3Shapes

Item {
    id: root

    property url source
    property size sourceSize
    property alias shape: fill.shape
    property alias color: fill.color
    property alias animationDuration: fill.animationDuration
    property alias animationEasing: fill.animationEasing

    readonly property bool hasImage: image.status === Image.Ready

    implicitWidth: 56
    implicitHeight: 56

    MaterialShape {
        id: fill
        anchors.fill: parent
        shape: MaterialShape.Cookie9Sided
        color: "transparent"
    }

    MaterialShape {
        id: mask
        anchors.fill: parent
        shape: fill.shape
        color: "black"
        animationDuration: fill.animationDuration
        animationEasing: fill.animationEasing
        layer.enabled: true
        visible: false
    }

    Image {
        id: image
        anchors.fill: parent
        source: root.source
        sourceSize: root.sourceSize
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: image
        visible: root.hasImage
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }
}
