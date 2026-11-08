import QtQuick
import QtQuick.Effects
import qs.services
import qs.theme

Item {
    id: root

    Image {
        id: picture

        anchors.fill: parent
        source: Wallpaper.url(Wallpaper.still)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(root.width * Theme.lock.blurSource, root.height * Theme.lock.blurSource)
        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.slow }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: Theme.lock.blurMax
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.lock.space
        opacity: Theme.lock.backdropDim
    }
}
