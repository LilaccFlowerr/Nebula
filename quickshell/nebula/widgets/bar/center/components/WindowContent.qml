import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.services
import qs.theme

RowLayout {
    id: root

    property int maxTitleWidth: 360

    spacing: Theme.spacing.xs

    IconImage {
        source: ActiveWindow.icon
        implicitSize: Theme.button.iconSize
        visible: source !== ""
    }

    Text {
        Layout.maximumWidth: root.maxTitleWidth
        elide: Text.ElideRight
        text: ActiveWindow.title
        color: Colors.textOnSurface
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
    }
}
