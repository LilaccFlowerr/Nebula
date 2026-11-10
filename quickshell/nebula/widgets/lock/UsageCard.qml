import QtQuick
import Quickshell
import M3Shapes
import qs.theme

Item {
    id: root

    property real value: 0
    property color colorFill: Colors.primary
    property color onFill: Colors.textOnPrimary
    property int chipShape: MaterialShape.Cookie6Sided
    property string icon: ""
    property string title: ""
    property string valueText: ""
    property string subText: ""
    property bool live: true
    property real phase: 0.8

    default property alias childItems: custom.data

    property real shown: Math.max(0, Math.min(1, value))
    readonly property real fillRatio: shown
    readonly property real cardRadius: Theme.radius.large

    Behavior on shown {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }
    readonly property real waveAmp: fillRatio > 0.01 && fillRatio < 0.99 ? 5 * Math.sin(fillRatio * Math.PI) : 0
    readonly property real waveOffset: waveAmp > 0 ? 0.375 * waveAmp * (Math.sin(phase) - Math.cos(phase)) : 0

    onValueChanged: {
        if (visible && live && fillRatio > 0.001 && fillRatio < 0.999) {
            if (!waveAnim.running) waveAnim.start();
            settle.restart();
        }
    }

    onVisibleChanged: {
        if (!visible) {
            waveAnim.stop();
            settle.stop();
        }
    }

    Timer {
        id: settle
        interval: 1600
        onTriggered: waveAnim.stop()
    }

    NumberAnimation {
        id: waveAnim
        target: root
        property: "phase"
        from: 0
        to: Math.PI * 2
        loops: Animation.Infinite
        duration: 1800
    }

    Rectangle {
        anchors.fill: parent
        radius: root.cardRadius
        color: Qt.alpha(Colors.surfaceContainerHigh, Theme.lock.surfaceTint)
        border.width: 1
        border.color: Qt.alpha(Colors.textOnSurface, 0.06)
    }

    ShaderEffect {
        anchors.fill: parent
        visible: root.fillRatio > 0.001

        property color color1: Qt.lighter(root.colorFill, 1.12)
        property color color2: root.colorFill
        property vector2d itemSize: Qt.vector2d(width, height)
        property real radius: root.cardRadius
        property real fillLevel: root.fillRatio
        property real waveAmp: root.waveAmp
        property real phase: root.phase

        fragmentShader: "file://" + Quickshell.shellPath("shaders/liquid.frag.qsb")
    }

    UsageContent {
        anchors.fill: parent
        chipShape: root.chipShape
        icon: root.icon
        title: root.title
        subText: root.subText
        valueText: root.valueText
        iconBg: Qt.alpha(root.colorFill, 0.22)
        iconFg: root.colorFill
        titleColor: Colors.textOnSurfaceVariant
        subColor: Colors.textOnSurfaceVariant
        valueColor: Colors.textOnSurface
    }

    Item {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.min(parent.height, Math.max(0, parent.height * root.fillRatio - root.waveOffset))
        clip: true
        visible: root.fillRatio > 0

        UsageContent {
            anchors.bottom: parent.bottom
            width: root.width
            height: root.height
            chipShape: root.chipShape
            icon: root.icon
            title: root.title
            subText: root.subText
            valueText: root.valueText
            iconBg: Qt.alpha(root.onFill, 0.2)
            iconFg: root.onFill
            titleColor: Qt.alpha(root.onFill, 0.85)
            subColor: root.onFill
            valueColor: root.onFill
        }
    }

    Item {
        id: custom

        anchors.fill: parent
        z: 10
    }
}
