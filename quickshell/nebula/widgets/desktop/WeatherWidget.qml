import QtQuick
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property string shapeName: "Cookie9Sided"
    property real baseSize: 220
    property string colorRole: "primary"
    property bool followWeather: true
    readonly property var palette: Widgets.palette(colorRole)
    readonly property var now: Weather.current
    readonly property var today: Weather.today
    readonly property var look: now ? Weather.describe(now.code, now.day) : null
    readonly property bool hasData: Weather.enabled && now !== null

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

    Component.onCompleted: Weather.refreshIfOld()

    GlassShape {
        id: body
        anchors.fill: parent
        shape: root.hasData && root.followWeather ? root.look.shape : (MaterialShape[root.shapeName] ?? MaterialShape.Cookie9Sided)
        fill: root.palette.fill
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.OutBack
        animationEasing.overshoot: Theme.anim.overshoot
    }

    Column {
        anchors.centerIn: parent
        spacing: root.size * 0.01
        opacity: root.hasData ? 1 : 0
        scale: root.hasData ? 1 : 0.8
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.medium }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.look?.icon ?? ""
            font.family: Theme.font.icons
            font.pixelSize: root.size * 0.15
            color: root.palette.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (root.now?.temp ?? "") + "°"
            font.family: Theme.font.family
            font.pixelSize: root.size * 0.25
            font.weight: Font.DemiBold
            color: root.palette.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(implicitWidth, root.size * 0.6)
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.look?.text ?? ""
            font.family: Theme.font.family
            font.pixelSize: root.size * 0.07
            color: root.palette.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.today !== null
            text: "↑" + (root.today?.max ?? "") + "°  ↓" + (root.today?.min ?? "") + "°"
            font.family: Theme.font.family
            font.pixelSize: root.size * 0.06
            color: root.palette.text
            opacity: 0.7
        }
    }

    LoadingIndicator {
        anchors.centerIn: parent
        width: root.size * 0.3
        height: width
        contained: false
        running: Weather.enabled && Weather.loading && root.now === null
        visible: running
    }

    Column {
        anchors.centerIn: parent
        spacing: root.size * 0.02
        visible: !Weather.enabled || (Weather.error !== "" && root.now === null)

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Weather.enabled ? "cloud_off" : "location_off"
            font.family: Theme.font.icons
            font.pixelSize: root.size * 0.14
            color: root.palette.text
            opacity: 0.7
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.size * 0.6
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: Weather.enabled ? "No weather right now" : "No city yet"
            font.family: Theme.font.family
            font.pixelSize: root.size * 0.065
            font.weight: Font.DemiBold
            color: root.palette.text
        }
    }
}
