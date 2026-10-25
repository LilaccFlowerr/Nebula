import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.theme
import qs.widgets.desktop.nowplaying

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: window

        required property ShellScreen modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        mask: dragging ? fullMask : boundsMask

        property bool dragging: false
        property var hovering: []

        function setHover(id, on) {
            if (hovering.includes(id) === on) return;
            const rest = hovering.filter(h => h !== id);
            hovering = on ? rest.concat([id]) : rest;
        }

        function stackOf(id) {
            return (Widgets.get(id)?.z ?? 0) * 1000 + Widgets.ids.indexOf(id);
        }

        readonly property string topHover: hovering.reduce((best, id) => best === "" || stackOf(id) > stackOf(best) ? id : best, "")
        property Region boundsMask: Region { item: bounds }
        property Region fullMask: Region {
            width: window.width
            height: window.height
        }

        readonly property bool covered: modelData ? Hyprland.monitorFor(modelData)?.activeWorkspace?.hasFullscreen ?? false : false

        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell:widgets"

        function updateBounds() {
            let left = Infinity, top = Infinity, right = -Infinity, bottom = -Infinity;
            for (let i = 0; i < repeater.count; i++) {
                const item = repeater.itemAt(i);
                if (!item || !item.active || item.leaving) continue;
                left = Math.min(left, item.x);
                top = Math.min(top, item.y);
                right = Math.max(right, item.x + item.width);
                bottom = Math.max(bottom, item.y + item.height);
            }
            if (left === Infinity) {
                bounds.x = 0;
                bounds.y = 0;
                bounds.width = 0;
                bounds.height = 0;
                return;
            }
            bounds.x = left;
            bounds.y = top;
            bounds.width = right - left;
            bounds.height = bottom - top;
        }

        Item {
            id: bounds
        }

        Component {
            id: nowPlayingWidget

            NowPlaying {
                live: !window.covered
                shapeName: parent?.cfg?.shape ?? "Cookie12Sided"
                colorRole: parent?.cfg?.color ?? "secondary"
                baseSize: parent?.cfg?.size ?? Theme.nowPlaying.cookieSize
            }
        }

        Component {
            id: imageWidget

            ImageWidget {
                shapeName: parent?.cfg?.shape ?? "Clover4Leaf"
                colorRole: parent?.cfg?.color ?? "secondary"
                baseSize: parent?.cfg?.size ?? 200
                path: parent?.cfg?.source ?? ""
                cropZoom: parent?.cfg?.zoom ?? 1
                cropX: parent?.cfg?.panX ?? 0
                cropY: parent?.cfg?.panY ?? 0
            }
        }

        Component {
            id: textWidget

            TextWidget {
                shapeName: parent?.cfg?.shape ?? "Sunny"
                colorRole: parent?.cfg?.color ?? "tertiary"
                textScale: parent?.cfg?.textScale ?? 1
                baseSize: parent?.cfg?.size ?? 180
                content: parent?.cfg?.source ?? ""
            }
        }

        Component {
            id: batteryWidget

            BatteryWidget {
                shapeName: parent?.cfg?.shape ?? "Cookie12Sided"
                colorRole: parent?.cfg?.color ?? "secondary"
                baseSize: parent?.cfg?.size ?? 200
            }
        }

        Component {
            id: calendarWidget

            CalendarWidget {
                shapeName: parent?.cfg?.shape ?? "Cookie9Sided"
                colorRole: parent?.cfg?.color ?? "tertiary"
                baseSize: parent?.cfg?.size ?? 200
                openShapeName: parent?.cfg?.openShape ?? ""
            }
        }

        Component {
            id: weatherWidget

            WeatherWidget {
                shapeName: parent?.cfg?.shape ?? "Cookie9Sided"
                colorRole: parent?.cfg?.color ?? "primary"
                baseSize: parent?.cfg?.size ?? 220
                followWeather: parent?.cfg?.follow ?? true
            }
        }

        Component {
            id: clockWidget

            ClockWidget {
                live: !window.covered
                shapeName: parent?.cfg?.shape ?? "Cookie12Sided"
                colorRole: parent?.cfg?.color ?? "primary"
                baseSize: parent?.cfg?.size ?? 220
                showSeconds: parent?.cfg?.seconds ?? true
                showDate: parent?.cfg?.date ?? true
                showNumbers: parent?.cfg?.numbers ?? false
                tickStyle: parent?.cfg?.tickStyle ?? "hours"
            }
        }

        Repeater {
            id: repeater
            model: Widgets.idModel
            onItemAdded: window.updateBounds()
            onItemRemoved: window.updateBounds()

            Loader {
                id: slot

                required property string modelData
                readonly property var cfg: Widgets.get(modelData) ?? ({})

                readonly property real maxX: Math.max(0, window.width - width)
                readonly property real maxY: Math.max(0, window.height - height)
                readonly property bool ghost: !!cfg.screen && Widgets.dragId === modelData && Widgets.dragSource !== window.modelData.name
                readonly property real restX: ghost ? Widgets.dragX - window.modelData.x
                    : (cfg.x ?? -1) < 0 ? Theme.nowPlaying.margin : Math.min(cfg.x, maxX)
                readonly property real restY: ghost ? Widgets.dragY - window.modelData.y
                    : (cfg.y ?? -1) < 0 ? maxY - Theme.nowPlaying.margin : Math.min(cfg.y, maxY)

                readonly property bool isTop: window.topHover === modelData
                readonly property real offX: ghost ? 0 : ((cfg.size ?? width) - width) / 2
                readonly property real offY: ghost ? 0 : ((cfg.size ?? height) - height) / 2

                property real shown: 1
                readonly property bool leaving: Widgets.leaving.includes(modelData)

                Connections {
                    target: Widgets
                    function onAdded(id) {
                        if (id !== slot.modelData) return;
                        slot.shown = 0;
                        popIn.start();
                    }
                }

                onLeavingChanged: {
                    window.updateBounds();
                    if (!leaving) return;
                    popIn.stop();
                    popOut.start();
                }

                NumberAnimation {
                    id: popIn
                    target: slot
                    property: "shown"
                    to: 1
                    duration: Theme.anim.slow
                    easing.type: Easing.OutBack
                    easing.overshoot: Theme.anim.overshoot
                }

                NumberAnimation {
                    id: popOut
                    target: slot
                    property: "shown"
                    to: 0
                    duration: Theme.anim.medium
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.emphasizedAccel
                }

                enabled: !leaving
                scale: 0.5 + 0.5 * shown
                z: cfg.z ?? 0
                opacity: (cfg.opacity ?? 1) * Math.min(shown, 1)
                active: cfg.enabled === true && Widgets.types[cfg.type] !== undefined && (ghost || !cfg.screen || cfg.screen === window.modelData.name)
                x: restX + offX + (drag.active ? drag.translation.x : 0)
                y: restY + offY + (drag.active ? drag.translation.y : 0)
                width: item?.implicitWidth ?? 0
                height: item?.implicitHeight ?? 0

                onActiveChanged: window.updateBounds()
                onXChanged: window.updateBounds()
                onYChanged: window.updateBounds()
                onWidthChanged: window.updateBounds()
                onHeightChanged: window.updateBounds()

                sourceComponent: cfg.type === "image" ? imageWidget : cfg.type === "text" ? textWidget : cfg.type === "clock" ? clockWidget : cfg.type === "calendar" ? calendarWidget : cfg.type === "battery" ? batteryWidget : cfg.type === "weather" ? weatherWidget : nowPlayingWidget

                HoverHandler {
                    enabled: !slot.ghost
                    blocking: false
                    onHoveredChanged: window.setHover(slot.modelData, hovered)
                }

                TapHandler {
                    enabled: !slot.ghost && slot.isTop
                    gesturePolicy: TapHandler.DragThreshold
                    onPressedChanged: if (pressed) Widgets.raise(slot.modelData)
                }

                TapHandler {
                    enabled: !slot.ghost && slot.isTop
                    acceptedButtons: Qt.RightButton
                    onTapped: Widgets.openMenu(slot.modelData, window.modelData.name, Qt.rect(window.modelData.x + slot.x, window.modelData.y + slot.y, slot.width, slot.height))
                }

                DragHandler {
                    id: drag
                    target: null
                    enabled: !slot.ghost && (slot.isTop || drag.active)
                    cursorShape: Qt.ClosedHandCursor

                    function publish() {
                        Widgets.dragX = window.modelData.x + slot.restX + slot.offX + translation.x;
                        Widgets.dragY = window.modelData.y + slot.restY + slot.offY + translation.y;
                    }

                    onTranslationChanged: if (active) publish()

                    onActiveChanged: {
                        window.dragging = active;
                        if (active) {
                            Widgets.dragSource = window.modelData.name;
                            publish();
                            Widgets.dragId = slot.modelData;
                            return;
                        }
                        const roam = !!slot.cfg.screen;
                        const target = roam ? Widgets.screenAt(Widgets.dragX + slot.width / 2, Widgets.dragY + slot.height / 2) : window.modelData;
                        const props = {
                            x: Math.round(Math.max(0, Math.min(Widgets.dragX - target.x, target.width - slot.width)) - slot.offX),
                            y: Math.round(Math.max(0, Math.min(Widgets.dragY - target.y, target.height - slot.height)) - slot.offY)
                        };
                        if (roam) props.screen = target.name;
                        Widgets.update(slot.modelData, props);
                        Widgets.dragId = "";
                    }
                }
            }
        }
    }
}
