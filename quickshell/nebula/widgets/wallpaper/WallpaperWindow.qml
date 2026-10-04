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

        property url target
        property real reveal: 0
        readonly property string style: Wallpaper.transition.key
        property real endScale: 1
        property real stretch: 1

        function measure() {
            let inner = Theme.launcher.previewSize / 2;
            for (let a = 0; a < 360; a += 3) inner = Math.min(inner, revealShape.distanceAtAngle(a));
            const ratio = inner / (Theme.launcher.previewSize / 2);
            endScale = Math.hypot(width, height) / 2 / inner * 1.02;
            stretch = Math.min(1.6, 0.89 / ratio);
        }

        function show(path) {
            target = Wallpaper.url(path);
            if (String(base.source) === String(target) && !incoming.visible) return;
            if (base.status !== Image.Ready || style === "none") {
                base.source = target;
                return;
            }
            play();
        }

        function play() {
            revealAnim.stop();
            measure();
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
            function onReplayRequested() { if (window.style !== "none" && base.status === Image.Ready) window.play(); }
        }

        NumberAnimation {
            id: revealAnim
            target: window
            property: "reveal"
            to: 1
            duration: window.style === "fade" ? Theme.anim.slow : Theme.anim.slow * 2 * window.stretch
            easing.type: Easing.BezierSpline
            easing.bezierCurve: window.style === "fade" ? Theme.anim.standard : Theme.anim.emphasizedDecel
            onFinished: {
                if (String(base.source) === String(window.target)) incoming.visible = false;
                else base.source = window.target;
            }
        }

        Image {
            id: base
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: window.width
            sourceSize.height: window.height
            onStatusChanged: if (status === Image.Ready && String(source) === String(window.target) && window.reveal === 1) incoming.visible = false
        }

        Image {
            id: incoming
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: window.width
            sourceSize.height: window.height
            visible: false
            opacity: window.style === "fade" ? window.reveal : 1
            onStatusChanged: if (status === Image.Ready && String(source) === String(window.target) && window.reveal === 0) revealAnim.restart()
            layer.enabled: visible && window.style !== "fade"
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
                id: revealShape
                anchors.centerIn: parent
                width: Theme.launcher.previewSize
                height: Theme.launcher.previewSize
                shape: Wallpaper.transitionShape
                animationDuration: 0
                color: "black"
                scale: 1 + (window.endScale - 1) * window.reveal
                rotation: (1 - window.reveal) * -90
            }
        }
    }
}
