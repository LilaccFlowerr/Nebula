import QtQuick
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    readonly property real cpu: SystemStats.cpu
    readonly property real temp: SystemStats.cpuTemp
    readonly property real mem: SystemStats.mem
    readonly property real memGb: SystemStats.memUsed / 1073741824
    readonly property real gpu: SystemStats.gpuLoad
    readonly property real disk: SystemStats.disk
    readonly property real netDown: SystemStats.netDown
    readonly property real netUp: SystemStats.netUp
    function gb(bytes) {
        return (bytes / 1073741824).toFixed(1) + "G";
    }

    function speed(bytes) {
        if (!(bytes >= 1)) return "0 B/s";
        const sizes = ["B/s", "KB/s", "MB/s", "GB/s"];
        const i = Math.min(sizes.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)));
        return parseFloat((bytes / Math.pow(1024, i)).toFixed(1)) + " " + sizes[i];
    }


    Item {
        id: box

        readonly property real gap: 10
        readonly property real cardW: (width - gap * 2) / 3
        readonly property real cardH: (height - gap) / 2

        width: Theme.lock.statsWidth
        height: Theme.lock.statsHeight
        scale: root.width / width
        transformOrigin: Item.TopLeft

        UsageCard {
            x: 0
            y: 0
            width: box.cardW
            height: box.cardH
            value: root.cpu
            colorFill: Colors.primary
            onFill: Colors.textOnPrimary
            chipShape: MaterialShape.Cookie6Sided
            icon: "memory"
            title: "CPU"
            valueText: Math.round(root.cpu * 100) + "%"
        }

        UsageCard {
            x: box.cardW + box.gap
            y: 0
            width: box.cardW
            height: box.cardH
            value: root.mem
            colorFill: Colors.secondary
            onFill: Colors.textOnSecondary
            chipShape: MaterialShape.Cookie9Sided
            icon: "memory_alt"
            title: "RAM"
            valueText: root.memGb.toFixed(1) + "G"
        }

        UsageCard {
            x: (box.cardW + box.gap) * 2
            y: 0
            width: box.cardW
            height: box.cardH
            value: root.gpu
            colorFill: Colors.tertiary
            onFill: Colors.textOnTertiary
            chipShape: MaterialShape.Clover4Leaf
            icon: "developer_board"
            title: "GPU"
            subText: SystemStats.useNvidia ? Math.round(SystemStats.nvidiaTemp) + "°" : ""
            valueText: Math.round(root.gpu * 100) + "%"
        }

        UsageCard {
            x: 0
            y: box.cardH + box.gap
            width: box.cardW
            height: box.cardH
            value: Math.max(0, Math.min(1, root.temp / 100))
            colorFill: Colors.primary
            onFill: Colors.textOnPrimary
            chipShape: MaterialShape.Sunny
            icon: "thermostat"
            title: "TEMP"
            valueText: Math.round(root.temp) + "°"
        }

        UsageCard {
            x: box.cardW + box.gap
            y: box.cardH + box.gap
            width: box.cardW
            height: box.cardH
            value: root.disk
            colorFill: Colors.secondary
            onFill: Colors.textOnSecondary
            chipShape: MaterialShape.Pentagon
            icon: "storage"
            title: root.gb(SystemStats.diskTotal)
            subText: root.gb(SystemStats.diskUsed)
            valueText: Math.round(root.disk * 100) + "%"
        }

        UsageCard {
            x: (box.cardW + box.gap) * 2
            y: box.cardH + box.gap
            width: box.cardW
            height: box.cardH
            value: 0.04
            colorFill: Colors.tertiary
            onFill: Colors.textOnTertiary
            chipShape: MaterialShape.Circle
            icon: "swap_vert"
            title: "NET"

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 11
                spacing: 4

                SpeedPill {
                    width: parent.width
                    arrow: "arrow_downward"
                    accent: Colors.tertiary
                    text: root.speed(root.netDown)
                }

                SpeedPill {
                    width: parent.width
                    arrow: "arrow_upward"
                    accent: Colors.secondary
                    text: root.speed(root.netUp)
                }
            }
        }
    }
}
