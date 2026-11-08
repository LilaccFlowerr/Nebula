import QtQuick
import qs.theme

Item {
    id: root

    function rand(seed) {
        const x = Math.sin(seed * 12.9898 + 78.233) * 43758.5453;
        return x - Math.floor(x);
    }

    Canvas {
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = Theme.lock.star;
            for (let i = 0; i < Theme.galaxy.stars; i++) {
                const big = root.rand(i + 1) > 0.9;
                ctx.globalAlpha = big ? Theme.galaxy.starBright : Theme.galaxy.starFaint;
                ctx.beginPath();
                ctx.arc(root.rand(i + 2) * width, root.rand(i + 3) * height, big ? 1.4 : 0.8, 0, Math.PI * 2);
                ctx.fill();
            }
        }
    }

    Repeater {
        model: Theme.lock.twinklers

        Rectangle {
            required property int index

            x: root.rand(index * 7 + 101) * root.width
            y: root.rand(index * 7 + 102) * root.height
            width: 2
            height: 2
            radius: 1
            color: Theme.lock.star
            opacity: 0

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PauseAnimation { duration: 400 + root.rand(index + 300) * 3200 }
                NumberAnimation { to: 0.9; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0; duration: 1300; easing.type: Easing.InOutSine }
            }
        }
    }
}
