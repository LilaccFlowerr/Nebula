import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

Island {
    roundRight: true
    implicitWidth: row.implicitWidth + Theme.bar.padding * 2

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