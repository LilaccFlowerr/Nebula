import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

Island {
    detach: Theme.bar.leftT
    hookRight: true
    edgeLeft: true
    roundRight: true
    implicitWidth: row.implicitWidth + Theme.bar.padding * 2

    WheelHandler {
        property real delta: 0

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            delta += event.angleDelta.y;
            if (Math.abs(delta) < 120) return;
            if (delta < 0) Workspaces.next();
            else Workspaces.previous();
            delta = 0;
        }
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.padding
        spacing: Theme.bar.gap

        Repeater {
            model: Workspaces.groupSize

            WorkspaceButton {
                required property int index
                wsId: Workspaces.firstId + index
            }
        }
    }
}