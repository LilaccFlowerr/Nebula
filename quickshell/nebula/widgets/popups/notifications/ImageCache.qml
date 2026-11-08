import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

PanelWindow {
    id: window

    visible: Notifications.uncached.length > 0
    anchors {
        top: true
        left: true
    }
    implicitWidth: Theme.toast.iconSize * 2
    implicitHeight: Theme.toast.iconSize * 2
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell:imagecache"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Repeater {
        model: Notifications.uncached

        Image {
            id: image

            required property string modelData

            anchors.fill: parent
            source: modelData
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            opacity: 0

            onStatusChanged: {
                if (status === Image.Error) {
                    Notifications.cacheImage(modelData, "");
                } else if (status === Image.Ready) {
                    const original = modelData;
                    grabToImage(result => {
                        const path = Quickshell.cachePath("avatar-" + Date.now() + ".png");
                        Notifications.cacheImage(original, result.saveToFile(path) ? "file://" + path : "");
                    });
                }
            }
        }
    }
}
