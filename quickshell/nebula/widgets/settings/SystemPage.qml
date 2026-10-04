import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: page

    readonly property var tabs: ["displays", "power", "input"]
    property int tab: 0

    spacing: Theme.spacing.xl

    Component.onCompleted: {
        tab = Math.max(0, tabs.indexOf(GlobalStates.settingsTab));
        GlobalStates.settingsTab = "";
    }

    SegmentedButton {
        Layout.fillWidth: true
        options: ["Displays", "Power", "Input"]
        currentIndex: page.tab
        onSelected: index => page.tab = index
    }

    Loader {
        id: tabLoader
        Layout.fillWidth: true
        source: ["DisplaysTab.qml", "PowerTab.qml", "InputTab.qml"][page.tab]
        onLoaded: tabFade.restart()

        NumberAnimation {
            id: tabFade
            target: tabLoader
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }
}
