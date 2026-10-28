import QtQuick
import Quickshell
import Quickshell.Io
import M3Shapes
import qs.components
import qs.services
import qs.theme
import "../../components/Ansi.js" as Ansi

Item {
    id: root

    property bool live: true
    property string shapeName: "Square"
    property real baseSize: Theme.fetch.size
    property string colorRole: "surface"
    property string logoMode: "fastfetch"
    property string source: ""
    property string args: ""
    property int refresh: 60
    readonly property var palette: Widgets.palette(colorRole)

    readonly property var baseColors: [Colors.outline, Colors.errorColor, Colors.secondary, Colors.tertiary, Colors.primary, Colors.tertiary, Colors.secondary, palette.text]
    readonly property var ansiColors: baseColors.concat(baseColors).map(c => String(c))
    readonly property var swatchShapes: [MaterialShape.Circle, MaterialShape.Cookie4Sided, MaterialShape.Clover4Leaf, MaterialShape.Cookie6Sided, MaterialShape.Sunny, MaterialShape.Pentagon, MaterialShape.Gem, MaterialShape.Flower]

    property string infoRaw: ""
    property string logoRaw: ""
    readonly property var lines: Ansi.merge(Ansi.parse(infoRaw, ansiColors))
    readonly property var logoLines: Ansi.parse(logoRaw, ansiColors)
    readonly property url picture: Wallpaper.url(source !== "" ? source : Quickshell.env("HOME") + "/.face")
    readonly property string logoShape: shapeName === "Cookie9Sided" ? "Cookie12Sided" : "Cookie9Sided"
    readonly property bool showArt: logoMode !== "fastfetch" || logoLines.length === 0

    function fetch(flags) {
        return ["sh", "-c", "if [ -n \"$2\" ] || [ -f \"${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/config.jsonc\" ]; then exec fastfetch --pipe false $2 $3; else exec fastfetch -c \"$1\" --pipe false $3; fi",
            "sh", Quickshell.shellPath("assets/fastfetch.jsonc"), args, flags];
    }

    function run() {
        infoProc.running = true;
        logoProc.running = true;
    }

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

    property int version: 0

    function remeasure() {
        version++;
    }

    function reach(angle) {
        return ref.distanceAtAngle(((angle % 360) + 360) % 360) / ref.width;
    }
    readonly property bool backdrop: logoMode === "background"
    readonly property bool asciiLogo: !showArt
    readonly property real logoAspect: asciiLogo ? Math.max(1, logoLines.length) * metrics.lineSpacing / (Math.max(1, Ansi.columns(logoLines)) * metrics.averageCharacterWidth) : 1
    readonly property real stackLogoW: backdrop ? 0 : Math.min(infoW * Theme.fetch.stackLogo / Math.min(1, logoAspect), infoW)
    readonly property real stackLogoH: stackLogoW * logoAspect
    readonly property real sideLogoH: backdrop ? 0 : Math.min(infoH * Theme.fetch.sideLogo, infoW / logoAspect)
    readonly property real sideLogoW: sideLogoH / logoAspect
    readonly property real gap: backdrop ? 0 : Theme.fetch.gap
    readonly property real logoW: stacked ? stackLogoW : sideLogoW
    readonly property real logoH: stacked ? stackLogoH : sideLogoH
    readonly property real infoW: Math.max(1, info.implicitWidth)
    readonly property real infoH: Math.max(1, info.implicitHeight)

    function fit(w, h) {
        if (version < 1) return 0.01;
        const half = Math.sqrt(w * w + h * h) / 2;
        const corner = Math.atan2(w, h) * 180 / Math.PI;
        let s = Infinity;
        for (const a of [corner, 180 - corner, 180 + corner, 360 - corner]) s = Math.min(s, reach(a) / half);
        s = Math.min(s, reach(0) * 2 / h, reach(90) * 2 / w, reach(180) * 2 / h, reach(270) * 2 / w);
        return size * s * Theme.fetch.fill;
    }

    readonly property real sideScale: fit(sideLogoW + root.gap + infoW, Math.max(sideLogoH, infoH))
    readonly property real stackScale: fit(Math.max(stackLogoW, infoW), stackLogoH + root.gap + infoH)
    readonly property bool stacked: stackScale > sideScale
    readonly property real k: Math.max(sideScale, stackScale)

    onArgsChanged: run()
    Component.onCompleted: run()

    FontMetrics {
        id: metrics
        font.family: Theme.font.mono
        font.pixelSize: 100
    }

    Process {
        id: infoProc
        command: root.fetch("--logo none")
        stdout: StdioCollector {
            onStreamFinished: root.infoRaw = text
        }
    }

    Process {
        id: logoProc
        command: root.fetch("-s none")
        stdout: StdioCollector {
            onStreamFinished: root.logoRaw = text
        }
    }

    Timer {
        interval: Math.max(5, root.refresh) * 1000
        running: root.refresh > 0 && root.live
        repeat: true
        onTriggered: infoProc.running = true
    }

    MaterialShape {
        id: ref
        width: 200
        height: 200
        visible: false
        animationDuration: 0
        shape: MaterialShape[root.shapeName] ?? MaterialShape.Square
        onShapeChanged: Qt.callLater(root.remeasure)
        Component.onCompleted: Qt.callLater(root.remeasure)
    }

    ShapedArt {
        visible: root.backdrop
        anchors.fill: parent
        shape: MaterialShape[root.shapeName] ?? MaterialShape.Square
        color: root.palette.fill
        source: root.picture
        sourceSize: Qt.size(root.size * 2, root.size * 2)
    }

    MaterialShape {
        visible: root.backdrop
        anchors.fill: parent
        implicitSize: root.size
        shape: MaterialShape[root.shapeName] ?? MaterialShape.Square
        color: Qt.alpha(Colors.surface, Theme.fetch.backdropDim)
    }

    GlassShape {
        visible: !root.backdrop
        anchors.fill: parent
        shape: MaterialShape[root.shapeName] ?? MaterialShape.Square
        fill: root.palette.fill
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.OutBack
        animationEasing.overshoot: Theme.anim.overshoot
    }

    Item {
        id: content

        width: root.stacked ? Math.max(root.logoW, root.infoW) : root.logoW + root.gap + root.infoW
        height: root.stacked ? root.logoH + root.gap + root.infoH : Math.max(root.logoH, root.infoH)
        anchors.centerIn: parent
        scale: root.k

        Item {
            id: logo
            visible: !root.backdrop

            x: root.stacked ? (content.width - width) / 2 : 0
            y: root.stacked ? 0 : (content.height - height) / 2
            width: root.logoW
            height: root.logoH

            ShapedArt {
                visible: root.showArt
                anchors.fill: parent
                shape: MaterialShape[root.logoShape]
                color: Colors.primaryContainer
                source: root.picture
                sourceSize: Qt.size(root.logoW * 2, root.logoH * 2)
            }

            Column {
                id: ascii

                readonly property real fontSize: root.logoW / (Math.max(1, Ansi.columns(root.logoLines)) * metrics.averageCharacterWidth / 100)

                visible: root.asciiLogo
                anchors.centerIn: parent

                Repeater {
                    model: root.logoLines

                    Text {
                        required property var modelData

                        textFormat: Text.RichText
                        text: modelData.html
                        font.family: Theme.font.mono
                        font.weight: Font.Bold
                        font.pixelSize: Math.max(1, ascii.fontSize)
                        lineHeight: 1
                        color: Colors.primary
                    }
                }
            }
        }

        Column {
            id: info

            x: root.stacked ? (content.width - root.infoW) / 2 : root.logoW + root.gap
            y: root.stacked ? root.logoH + root.gap : (content.height - root.infoH) / 2

            Repeater {
                model: root.lines

                Item {
                    id: line

                    required property var modelData

                    implicitWidth: modelData.palette ? swatches.implicitWidth : label.implicitWidth
                    implicitHeight: modelData.palette ? Theme.fetch.textSize * Theme.fetch.swatchScale + Theme.fetch.swatchGap : label.implicitHeight

                    Text {
                        id: label
                        visible: !line.modelData.palette
                        textFormat: Text.RichText
                        text: line.modelData.html
                        font.family: Theme.font.mono
                        font.pixelSize: Theme.fetch.textSize
                        color: root.palette.text
                    }

                    Row {
                        id: swatches
                        visible: !!line.modelData.palette
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.fetch.textSize * Theme.fetch.swatchSpacing

                        Repeater {
                            model: line.modelData.palette ?? []

                            MaterialShape {
                                required property var modelData
                                required property int index

                                implicitSize: Theme.fetch.textSize * Theme.fetch.swatchScale
                                width: implicitSize
                                height: implicitSize
                                shape: root.swatchShapes[index % root.swatchShapes.length]
                                color: modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
