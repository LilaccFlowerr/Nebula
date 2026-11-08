import QtQuick
import qs.theme

Canvas {
    id: root

    property real shown: 1

    function rand(seed) {
        const x = Math.sin(seed * 12.9898 + 78.233) * 43758.5453;
        return x - Math.floor(x);
    }

    opacity: shown
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = Colors.textOnSurface;
        for (let i = 0; i < Theme.galaxy.stars; i++) {
            const big = rand(i + 1) > 0.9;
            ctx.globalAlpha = big ? Theme.galaxy.starBright : Theme.galaxy.starFaint;
            ctx.beginPath();
            ctx.arc(rand(i + 2) * width, rand(i + 3) * height, big ? 1.4 : 0.8, 0, Math.PI * 2);
            ctx.fill();
        }
    }
}
