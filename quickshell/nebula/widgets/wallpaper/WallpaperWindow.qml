import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import M3Shapes
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

        property Image base: first
        property Image incoming: second
        property url target
        property bool busy: false
        property bool prepared: false
        property bool replayPending: false
        property real reveal: 0
        property string style: "none"
        property int transitionShape: MaterialShape.Cookie9Sided
        property real endScale: 1
        property real stretch: 1
        readonly property bool shaped: style !== "none" && style !== "fade" && style !== "glitch"

        function measure() {
            let inner = Theme.launcher.previewSize / 2;
            for (let a = 0; a < 360; a += 3) inner = Math.min(inner, revealShape.distanceAtAngle(a));
            inner = Math.max(1, inner);
            const ratio = inner / (Theme.launcher.previewSize / 2);
            endScale = Math.hypot(width, height) / 2 / inner * 1.02;
            stretch = Math.min(1.6, 0.89 / ratio);
        }

        function show() {
            if (busy) return;
            target = Wallpaper.url(Wallpaper.current);
            if (String(base.source) === String(target) && !replayPending) {
                Wallpaper.settled();
                return;
            }
            replayPending = false;
            style = base.status === Image.Ready ? Wallpaper.transition.key : "none";
            transitionShape = Wallpaper.transitionShape;
            reveal = 0;
            prepared = false;
            busy = true;
            incoming.source = target;
            Qt.callLater(prepare);
        }

        function prepare() {
            if (!busy || prepared) return;
            if (incoming.status === Image.Error) {
                busy = false;
                console.warn("Unable to load wallpaper:", target);
                if (String(target) !== String(Wallpaper.url(Wallpaper.current))) Qt.callLater(show);
                return;
            }
            if (incoming.status !== Image.Ready) return;
            if (style === "none") {
                finish();
                return;
            }
            if (shaped) measure();
            prepared = true;
            prime.frames = 0;
            prime.start();
        }

        function finish() {
            const previous = base;
            base = incoming;
            incoming = previous;
            prepared = false;
            busy = false;
            if (String(target) !== String(Wallpaper.url(Wallpaper.current)) || replayPending) Qt.callLater(show);
            else Wallpaper.settled();
        }

        Component.onCompleted: show()

        Connections {
            target: Wallpaper
            function onCurrentChanged() { window.show(); }
            function onReplayRequested() {
                window.replayPending = true;
                window.show();
            }
        }

        FrameAnimation {
            id: prime
            property int frames: 0
            onTriggered: {
                if (++frames < 3) return;
                stop();
                revealAnim.start();
            }
        }

        NumberAnimation {
            id: revealAnim
            target: window
            property: "reveal"
            from: 0
            to: 1
            duration: window.style === "fade" ? Theme.anim.slow : window.style === "glitch" ? Theme.anim.slow * 6 : Theme.anim.slow * 2 * window.stretch
            easing.type: window.style === "glitch" ? Easing.Linear : Easing.BezierSpline
            easing.bezierCurve: window.style === "fade" ? Theme.anim.standard : Theme.anim.emphasizedDecel
            onFinished: window.finish()
        }

        Image {
            id: first
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: window.width
            sourceSize.height: window.height
            visible: window.base === first
            onStatusChanged: Qt.callLater(window.prepare)
        }

        Image {
            id: second
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: window.width
            sourceSize.height: window.height
            visible: window.base === second
            onStatusChanged: Qt.callLater(window.prepare)
        }

        MultiEffect {
            anchors.fill: parent
            source: window.incoming
            visible: window.prepared && window.style !== "glitch"
            opacity: window.style === "fade" ? window.reveal : 1
            maskEnabled: window.shaped
            maskSource: maskTexture
            maskThresholdMin: 0.5
            maskSpreadAtMin: 0.02
            autoPaddingEnabled: false
        }

        Loader {
            anchors.fill: parent
            active: window.prepared && window.style === "glitch"

            sourceComponent: ShaderEffect {
                property variant from: ShaderEffectSource { sourceItem: window.base; live: false }
                property variant to: ShaderEffectSource { sourceItem: window.incoming; live: false }
                property real progress: window.reveal
                property color glow: Colors.primary
                fragmentShader: "file://" + Quickshell.shellPath("shaders/glitch.frag.qsb")
            }
        }

        ShaderEffectSource {
            id: maskTexture
            sourceItem: revealMask
            hideSource: true
            live: true
            visible: false
        }

        Item {
            id: revealMask
            anchors.fill: parent

            MaterialShape {
                id: revealShape
                anchors.centerIn: parent
                width: Theme.launcher.previewSize
                height: Theme.launcher.previewSize
                shape: window.transitionShape
                animationDuration: 0
                color: "black"
                scale: 1 + (window.endScale - 1) * window.reveal
                rotation: (1 - window.reveal) * -90
            }
        }
    }
}
