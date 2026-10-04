pragma Singleton

import QtQuick
import Quickshell

Singleton {
    component Bar: QtObject {
        readonly property int height: 55
        readonly property int padding: 16
        readonly property int gap: 14
        readonly property int radius: 16
        readonly property int centerMinWidth: 336
        readonly property int eventArtSize: 22
        readonly property int notificationWidth: 400
        readonly property int notificationIconSize: 36
        readonly property int notificationBadgeSize: 18
        readonly property int notificationMaxLines: 6
        readonly property int windowHeight: 480
        readonly property real opacity: 0.85
    }
    readonly property Bar bar: Bar {}

    component Button: QtObject {
        readonly property int size: 40
        readonly property int iconSize: 20
    }
    readonly property Button button: Button {}

    component Workspaces: QtObject {
        readonly property int shown: 5
        readonly property int activeWidth: 88
    }
    readonly property Workspaces workspaces: Workspaces {}

    component BatteryRing: QtObject {
        readonly property int size: 50
        readonly property int thickness: 3
        readonly property real trackOpacity: 0.28
        readonly property real lowLevel: 0.2
    }
    readonly property BatteryRing batteryRing: BatteryRing {}

    component QuickSettings: QtObject {
        readonly property int width: 420
        readonly property int avatarSize: 96
        readonly property int avatarIconSize: 32
        readonly property int tileHeight: 56
        readonly property int tileInnerRadius: 4
        readonly property int tileGap: 2
        readonly property int tileIconSize: 24
        readonly property int neckWidth: 40
        readonly property int neckCurve: 12
    }
    readonly property QuickSettings quickSettings: QuickSettings {}

    component RecorderCorner: QtObject {
        readonly property int windowSize: 480
        readonly property int margin: 24
        readonly property int hotWidth: 300
        readonly property int hotHeight: 10
        readonly property int openWidth: 280
        readonly property int tabHeight: 40
        readonly property int flare: 16
        readonly property int closeDelay: 150
        readonly property int savedDuration: 6000
        readonly property int buttonSize: 72
        readonly property int timerSize: 32
        readonly property int rowHeight: 40
    }
    readonly property RecorderCorner recorder: RecorderCorner {}

    component NowPlaying: QtObject {
        readonly property int margin: 32
        readonly property int cookieSize: 280
        readonly property int artSize: 88
        readonly property int textWidth: 170
        readonly property int progressWidth: 140
        readonly property int spinDuration: 30000
        readonly property int spinUpDuration: 1200
        readonly property int emptySize: 120
        readonly property int emptyIconSize: 48
    }
    readonly property NowPlaying nowPlaying: NowPlaying {}

    component Launcher: QtObject {
        readonly property int size: 380
        readonly property int ringRadius: 136
        readonly property int itemSize: 50
        readonly property int selectionSize: 55
        readonly property int labelGap: 4
        readonly property int stagger: 25
        readonly property int previewSize: 170
        readonly property int wallpaperPillOffset: 220
        readonly property int labelWidth: 80
        readonly property int iconSize: 26
        readonly property real leafRadius: 0.654
        readonly property real valleyRadius: 0.464
        readonly property real leafRounding: 0.209
        readonly property int searchWidth: 150
        readonly property int searchHeight: 40
        readonly property real dim: 0.4
    }
    readonly property Launcher launcher: Launcher {}

    component Lyrics: QtObject {
        readonly property int lineHeight: 20
        readonly property int titleWidth: 120
    }
    readonly property Lyrics lyrics: Lyrics {}

    component Visualizer: QtObject {
        readonly property real pillOpacity: 0.3
        readonly property real barWidth: 2
        readonly property int cardHeight: 120
    }
    readonly property Visualizer visualizer: Visualizer {}

    component Radius: QtObject {
        readonly property int small: 8
        readonly property int medium: 16
        readonly property int large: 24
        readonly property int full: 999
    }
    readonly property Radius radius: Radius {}

    component Spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 24
    }
    readonly property Spacing spacing: Spacing {}

    component Font: QtObject {
        readonly property string family: "Inter"
        readonly property string icons: "Material Symbols Rounded"
        readonly property string logos: "Symbols Nerd Font"
        readonly property int small: 12
        readonly property int normal: 14
        readonly property int large: 16
        readonly property int clock: 20
    }
    readonly property Font font: Font {}

    component Anim: QtObject {
        readonly property int fast: 150
        readonly property int medium: 300
        readonly property int slow: 500
        readonly property int island: 550
        readonly property real overshoot: 1.2

        readonly property list<real> standard:        [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    }
    readonly property Anim anim: Anim {}
}
