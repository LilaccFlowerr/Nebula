import QtQuick
import qs.theme

Rectangle {
    id: root

    property bool roundLeft: false
    property bool roundRight: false

    implicitHeight: Theme.bar.height
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    bottomLeftRadius: roundLeft ? Theme.bar.radius : 0
    bottomRightRadius: roundRight ? Theme.bar.radius: 0

}
