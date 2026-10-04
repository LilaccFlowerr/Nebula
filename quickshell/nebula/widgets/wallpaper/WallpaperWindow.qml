import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import M3Shapes
import qs.components
import qs.services
import qs.theme

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: window

        required property ShellScreen modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: Colors.surface
        mask: Region {}

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "quickshell:wallpaper"

        property string target: ""
        property real reveal: 0
        readonly property real endScale: Math.hypot(width, height) / (Theme.launcher.previewSize * 0.9)

        function show(path) {
            target = Wallpaper.url(path);
            if (String(base.source) === target && !incoming.visible) return;
            if (base.status !== Image.Ready) {
                base.source = target;
                return;
            }
            revealAnim.stop();
            reveal = 0;
            incoming.source = target;
            incoming.visible = true;
            if (incoming.status === Image.Ready) revealAnim.restart();
        }

        Component.onCompleted: {
            target = Wallpaper.url(Wallpaper.current);
            base.source = target;
        }

        Connections {
            target: Wallpaper
            function onCurrentChanged() { window.show(Wallpaper.current); }
        }

        NumberAnimation {
            id: revealAnim
            target: window
            property: "reveal"
            to: 1
            duration: Theme.anim.slow * 2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
            onFinished: base.source = window.target
        }

        Image {
            id: base
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: window.width
            sourceSize.height: window.height
            onStatusChanged: if (status === Image.Ready && String(source) === window.target && window.reveal === 1) incoming.visible = false
        }

        Image {
            id: incoming
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: window.width
            sourceSize.height: window.height
            visible: false
            onStatusChanged: if (status === Image.Ready && String(source) === window.target && window.reveal === 0) revealAnim.restart()
            layer.enabled: visible
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: revealMask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 0.02
            }
        }

        Item {
            id: revealMask
            anchors.fill: parent
            layer.enabled: true
            visible: false

            MaterialShape {
                anchors.centerIn: parent
                width: Theme.launcher.previewSize
                height: Theme.launcher.previewSize
                shape: MaterialShape.Cookie9Sided
                color: "black"
                scale: 1 + (window.endScale - 1) * window.reveal
                rotation: (1 - window.reveal) * -90
            }
        }
    }
}
