import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.services
import qs.theme

Rectangle {
    id: root

    component Stat: Rectangle {
        id: stat

        property string icon: ""
        property string label: ""
        property real value: 0
        property string text: Math.round(value * 100) + "%"
        property bool bar: true
        readonly property bool high: bar && value >= Theme.system.high

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: statColumn.implicitHeight + Theme.spacing.sm * 2 + Theme.spacing.xs
        radius: Theme.radius.medium
        color: Colors.surfaceContainerHigh

        Column {
            id: statColumn
            anchors.centerIn: parent
            width: parent.width - Theme.spacing.sm * 2
            spacing: Theme.spacing.xs

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: stat.label
                font.family: Theme.font.family
                font.pixelSize: Theme.system.labelSize
                font.weight: Font.DemiBold
                color: Colors.textOnSurfaceVariant
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: stat.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.system.tileIconSize
                color: stat.high ? Colors.errorColor : Colors.primary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: stat.text
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.Bold
                color: Colors.textOnSurface
            }

            Item {
                width: parent.width
                height: Theme.system.barHeight
                opacity: stat.bar ? 1 : 0

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Colors.secondaryContainer
                }

                Rectangle {
                    width: Math.max(height, parent.width * Math.min(1, stat.value))
                    height: parent.height
                    radius: height / 2
                    color: stat.high ? Colors.errorColor : Colors.primary

                    Behavior on width {
                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                    }
                }
            }
        }
    }

    component Hardware: RowLayout {
        id: hardware

        property string icon: ""
        property string name: ""

        Layout.fillWidth: true
        visible: name !== ""
        spacing: Theme.spacing.xs

        Text {
            text: hardware.icon
            font.family: Theme.font.icons
            font.pixelSize: Theme.system.hardwareIconSize
            color: Colors.primary
        }

        Text {
            Layout.fillWidth: true
            text: hardware.name
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            color: Colors.textOnSurfaceVariant
            elide: Text.ElideRight
        }
    }

    property bool open: false
    readonly property real load: SystemStats.cpu
    readonly property bool high: load >= Theme.system.high

    function speed(bytes) {
        return bytes >= 1e6 ? (bytes / 1e6).toFixed(1) + " MB/s" : Math.round(bytes / 1e3) + " kB/s";
    }

    onOpenChanged: SystemStats.users += open ? 1 : -1
    Component.onDestruction: if (open) SystemStats.users--

    implicitWidth: Theme.system.width
    implicitHeight: column.implicitHeight + Theme.spacing.lg * 2
    radius: Theme.radius.large
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.85
    transformOrigin: Item.TopRight

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }
    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        RowLayout {
            spacing: Theme.spacing.md

            MaterialShape {
                implicitSize: Theme.system.shapeSize
                implicitWidth: Theme.system.shapeSize
                implicitHeight: Theme.system.shapeSize
                shape: root.load < Theme.system.busy ? MaterialShape.Cookie9Sided : root.high ? MaterialShape.SoftBurst : MaterialShape.Sunny
                color: root.high ? Colors.errorContainer : Colors.primaryContainer

                Text {
                    anchors.centerIn: parent
                    text: "memory"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.system.iconSize
                    color: root.high ? Colors.textOnErrorContainer : Colors.textOnPrimaryContainer
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    spacing: Theme.spacing.sm

                    Text {
                        text: Math.round(root.load * 100) + "%"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.system.valueSize
                        font.weight: Font.Bold
                        color: Colors.textOnSurface
                    }

                    Text {
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: Theme.spacing.sm
                        text: Math.round(SystemStats.cpuTemp) + " °C"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        color: Colors.textOnSurfaceVariant
                    }
                }

                Hardware {
                    icon: "memory"
                    name: SystemStats.cpuName
                }

                Hardware {
                    icon: "developer_board"
                    name: SystemStats.gpuName
                }
            }
        }

        Canvas {
            id: graph

            readonly property var points: SystemStats.cpuHistory
            readonly property color lineColor: root.high ? Colors.errorColor : Colors.primary

            Layout.fillWidth: true
            implicitHeight: Theme.system.graphHeight

            onPointsChanged: requestPaint()
            onLineColorChanged: requestPaint()
            onWidthChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const count = points.length;
                if (count < 2) return;
                const top = Math.max(Theme.system.graphFloor, ...points);
                const step = width / (SystemStats.historyLength - 1);
                const start = width - (count - 1) * step;
                const pad = Theme.system.graphLine;
                const y = v => height - pad - v / top * (height - pad * 2);
                const line = () => {
                    ctx.beginPath();
                    ctx.moveTo(start, y(points[0]));
                    for (let i = 1; i < count; i++)
                        ctx.lineTo(start + i * step, y(points[i]));
                };
                line();
                ctx.lineTo(width, height);
                ctx.lineTo(start, height);
                ctx.closePath();
                ctx.fillStyle = Qt.alpha(lineColor, 0.15);
                ctx.fill();
                line();
                ctx.strokeStyle = lineColor;
                ctx.lineWidth = Theme.system.graphLine;
                ctx.lineJoin = "round";
                ctx.lineCap = "round";
                ctx.stroke();
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: stats.implicitHeight + Theme.spacing.md * 2
            radius: Theme.radius.large - Theme.spacing.xs
            color: Colors.surfaceContainer

            RowLayout {
                id: stats
                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                spacing: Theme.spacing.xs

                Stat {
                    icon: "memory_alt"
                    label: "RAM"
                    value: SystemStats.mem
                }

                Stat {
                    icon: "developer_board"
                    label: "GPU"
                    value: SystemStats.gpu
                }

                Stat {
                    icon: "hard_drive"
                    label: "Disk"
                    value: SystemStats.disk
                }

                Stat {
                    icon: "swap_vert"
                    label: "Network"
                    bar: false
                    text: root.speed(SystemStats.netDown)
                }
            }
        }
    }
}
