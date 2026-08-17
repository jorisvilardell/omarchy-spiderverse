import QtQuick
import "SpiderverseTheme.js" as Theme

// Comic-print dot texture (ported from the mockup's CSS radial-gradient
// backgrounds). True CSS mix-blend-mode:screen has no cheap QML equivalent at
// full-screen size, so this falls back to a low-opacity static overlay --
// visually close, painted once (not per-frame).
Canvas {
    id: halftone

    property real intensity: 0.5 // 0..1, mirrors the mockup's comicIntensity

    opacity: 0.02 + intensity * 0.07
    renderTarget: Canvas.Image
    renderStrategy: Canvas.Cooperative

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        ctx.fillStyle = "rgba(255, 45, 149, 0.55)";
        for (let y = 0; y < height; y += 7) {
            for (let x = 0; x < width; x += 7) {
                ctx.fillRect(x, y, 1.4, 1.4);
            }
        }

        ctx.fillStyle = "rgba(0, 229, 255, 0.4)";
        for (let y = 3; y < height; y += 11) {
            for (let x = 4; x < width; x += 11) {
                ctx.fillRect(x, y, 1.4, 1.4);
            }
        }
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
}
