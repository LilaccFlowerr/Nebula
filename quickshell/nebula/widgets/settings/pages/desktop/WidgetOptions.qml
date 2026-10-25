import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    property string arg: ""
    readonly property var cfg: Widgets.get(arg) ?? ({})

    signal navigate(string target)

    function set(props) {
        Widgets.update(arg, props);
    }

    readonly property bool hasOptions: ["text", "image", "clock", "calendar", "nowplaying", "weather"].includes(cfg.type)

    visible: hasOptions
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Text"
        visible: page.cfg.type === "text"

        SettingRow {
            icon: "edit_note"
            title: "Note"

            TextField {
                anchors.verticalCenter: parent.verticalCenter
                text: page.cfg.source ?? ""
                placeholder: "Write something"
                onEdited: text => page.set({ source: text })
            }
        }

        SettingRow {
            icon: "format_size"
            title: "Text size"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 50
                to: 200
                stepSize: 10
                value: (page.cfg.textScale ?? 1) * 100
                onMoved: page.set({ textScale: Math.round(value / 10) * 10 / 100 })
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Math.round((page.cfg.textScale ?? 1) * 100)
                from: 50
                to: 200
                step: 10
                suffix: " %"
                onEdited: value => page.set({ textScale: value / 100 })
            }
        }
    }

    SettingGroup {
        title: "Image"
        visible: page.cfg.type === "image"

        SettingRow {
            icon: "image"
            title: "Picture"
            subtitle: (page.cfg.source ?? "").split("/").pop()

            ActionButton {
                icon: "folder_open"
                text: "Change"
                filled: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    Widgets.replacing = page.arg;
                    page.navigate("images");
                }
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: cropEditor.height + Theme.spacing.lg * 2

            ShapedArt {
                id: cropEditor

                readonly property real zoomLevel: page.cfg.zoom ?? 1

                anchors.horizontalCenter: parent.horizontalCenter
                y: Theme.spacing.lg
                width: 220
                height: 220
                shape: MaterialShape[page.cfg.shape ?? "Clover4Leaf"] ?? MaterialShape.Clover4Leaf
                color: Widgets.palette(page.cfg.color).fill
                source: page.cfg.source ? Wallpaper.url(page.cfg.source) : ""
                sourceSize: Qt.size(1200, 1200)
                zoom: zoomLevel
                panX: page.cfg.panX ?? 0
                panY: page.cfg.panY ?? 0

                MouseArea {
                    id: cropMouse

                    property real lastX: 0
                    property real lastY: 0

                    anchors.fill: parent
                    preventStealing: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    onPressed: mouse => {
                        lastX = mouse.x;
                        lastY = mouse.y;
                    }
                    onPositionChanged: mouse => {
                        if (!pressed) return;
                        const dx = mouse.x - lastX;
                        const dy = mouse.y - lastY;
                        lastX = mouse.x;
                        lastY = mouse.y;
                        const props = {};
                        if (cropEditor.rangeX > 0) props.panX = Math.max(-1, Math.min(1, (page.cfg.panX ?? 0) - dx / cropEditor.rangeX));
                        if (cropEditor.rangeY > 0) props.panY = Math.max(-1, Math.min(1, (page.cfg.panY ?? 0) - dy / cropEditor.rangeY));
                        page.set(props);
                    }
                    onWheel: wheel => page.set({ zoom: Math.max(1, Math.min(4, Math.round((cropEditor.zoomLevel + wheel.angleDelta.y / 1200) * 100) / 100)) })
                }
            }
        }

        SettingRow {
            icon: "zoom_in"
            title: "Zoom"
            subtitle: "Drag the picture above to move it"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm - Theme.button.size
                anchors.verticalCenter: parent.verticalCenter
                from: 100
                to: 400
                stepSize: 5
                value: (page.cfg.zoom ?? 1) * 100
                onMoved: page.set({ zoom: Math.round(value / 5) * 5 / 100 })
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Math.round((page.cfg.zoom ?? 1) * 100)
                from: 100
                to: 400
                step: 5
                suffix: " %"
                onEdited: value => page.set({ zoom: value / 100 })
            }

            IconButton {
                icon: "restart_alt"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: page.set({ zoom: 1, panX: 0, panY: 0 })
            }
        }
    }

    SettingGroup {
        title: "Clock"
        visible: page.cfg.type === "clock"

        SettingRow {
            icon: "timer"
            title: "Seconds"
            subtitle: "A dot that runs along the edge"
            clickable: true
            onClicked: page.set({ seconds: !(page.cfg.seconds ?? true) })

            Switch {
                checked: page.cfg.seconds ?? true
                onToggled: page.set({ seconds: !(page.cfg.seconds ?? true) })
            }
        }

        SettingRow {
            icon: "calendar_today"
            title: "Date"
            subtitle: "Moves out of the way of the hands"
            clickable: true
            onClicked: page.set({ date: !(page.cfg.date ?? true) })

            Switch {
                checked: page.cfg.date ?? true
                onToggled: page.set({ date: !(page.cfg.date ?? true) })
            }
        }

        SettingRow {
            icon: "more_horiz"
            title: "Tick marks"

            SegmentedButton {
                readonly property var styles: ["off", "hours", "all"]

                width: Theme.settings.controlWidth
                anchors.verticalCenter: parent.verticalCenter
                options: ["Off", "Hours", "All"]
                currentIndex: Math.max(0, styles.indexOf(page.cfg.tickStyle ?? "hours"))
                onSelected: index => page.set({ tickStyle: styles[index] })
            }
        }

        SettingRow {
            icon: "pin"
            title: "Hour numbers"
            clickable: true
            onClicked: page.set({ numbers: !(page.cfg.numbers ?? false) })

            Switch {
                checked: page.cfg.numbers ?? false
                onToggled: page.set({ numbers: !(page.cfg.numbers ?? false) })
            }
        }
    }

    SettingGroup {
        title: "Calendar"
        visible: page.cfg.type === "calendar"

        SettingRow {
            icon: "open_in_full"
            title: "Open shape"
            subtitle: (page.cfg.openShape ?? "") === "" ? "Same shape" : page.cfg.openShape
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: openFlow.implicitHeight + Theme.spacing.md * 2

            Flow {
                id: openFlow
                x: Theme.spacing.md
                y: Theme.spacing.md
                width: parent.width - Theme.spacing.md * 2
                spacing: Theme.spacing.xs

                Repeater {
                    model: [""].concat(Widgets.shapes)

                    Rectangle {
                        id: openChip

                        required property string modelData
                        readonly property bool active: modelData === (page.cfg.openShape ?? "")

                        width: Theme.button.size
                        height: Theme.button.size
                        radius: active ? height / 2 : Theme.radius.medium
                        color: active ? Colors.secondaryContainer : openMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.08) : "transparent"

                        Behavior on radius {
                            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                        }

                        MaterialShape {
                            anchors.centerIn: parent
                            width: Theme.settings.iconSize
                            height: width
                            visible: openChip.modelData !== ""
                            shape: MaterialShape[openChip.modelData] ?? MaterialShape.Circle
                            color: openChip.active ? Colors.textOnSecondaryContainer : Colors.primary
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: openChip.modelData === ""
                            text: "filter_none"
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: openChip.active ? Colors.textOnSecondaryContainer : Colors.primary
                        }

                        MouseArea {
                            id: openMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.set({ openShape: openChip.modelData })
                        }
                    }
                }
            }
        }
    }

    SettingGroup {
        title: "Music"
        visible: page.cfg.type === "nowplaying"

        SettingRow {
            icon: "autorenew"
            title: "Spin while playing"
            subtitle: "Turns slowly while music plays"
            clickable: true
            onClicked: Settings.nowPlaying.spin = !Settings.nowPlaying.spin

            Switch {
                checked: Settings.nowPlaying.spin
                onToggled: Settings.nowPlaying.spin = !Settings.nowPlaying.spin
            }
        }

        SettingRow {
            icon: "speed"
            title: "Spin speed"
            subtitle: "Seconds per turn"
            visible: Settings.nowPlaying.spin

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 20
                to: 180
                stepSize: 5
                value: Settings.nowPlaying.spinSeconds
                onMoved: Settings.nowPlaying.spinSeconds = Math.round(value / 5) * 5
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.nowPlaying.spinSeconds
                from: 20
                to: 180
                step: 5
                suffix: " s"
                onEdited: value => Settings.nowPlaying.spinSeconds = value
            }
        }
    }

    SettingGroup {
        title: "Weather"
        visible: page.cfg.type === "weather"

        SettingRow {
            icon: "partly_cloudy_day"
            title: "Shape follows weather"
            subtitle: "Sunny when clear, puffy when cloudy, … Off uses the shape above"
            clickable: true
            onClicked: page.set({ follow: !(page.cfg.follow ?? true) })

            Switch {
                checked: page.cfg.follow ?? true
                onToggled: page.set({ follow: !(page.cfg.follow ?? true) })
            }
        }
    }
}
