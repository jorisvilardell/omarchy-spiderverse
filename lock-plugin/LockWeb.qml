import QtQuick
import QtQuick.Shapes
import "LockTheme.js" as Theme

// Radial web background: 16 fixed spokes + 4 rings around the hub. Spokes
// light up progressively with `liveCount` (mirrors the mockup, driven by the
// real typed-password length -- the same length already shown via the
// existing password dots, not a new leak) instead of representing app nodes
// like the launcher's SpiderWeb.
Item {
    id: web

    property real centerX: width / 2
    property real centerY: height / 2
    property real hubRadius: 150
    property real maxRadius: 600
    property int spokeCount: 16
    property int liveCount: 0
    property bool denied: false
    property int pulseTick: 0
    property color accentColor: Theme.accent

    readonly property color hotColor: denied ? Theme.red : accentColor
    readonly property color coldColor: Qt.rgba(0.6, 0.53, 0.76, 0.2)

    readonly property var ringRatios: [0.41, 0.6, 0.79, 1.0]

    function svgLine(x1, y1, x2, y2) {
        return "M " + x1 + " " + y1 + " L " + x2 + " " + y2;
    }

    readonly property string coldSpokesSvg: {
        var parts = [];
        for (var i = liveCount; i < spokeCount; i++) {
            var deg = -90 + (i * 360) / spokeCount;
            var rad = (deg * Math.PI) / 180;
            var rr = maxRadius;
            parts.push(svgLine(
                centerX + Math.cos(rad) * hubRadius, centerY + Math.sin(rad) * hubRadius,
                centerX + Math.cos(rad) * rr, centerY + Math.sin(rad) * rr
            ));
        }
        return parts.join(" ");
    }

    readonly property string hotSpokesSvg: {
        var parts = [];
        for (var i = 0; i < liveCount; i++) {
            var deg = -90 + (i * 360) / spokeCount;
            var rad = (deg * Math.PI) / 180;
            var rr = maxRadius;
            parts.push(svgLine(
                centerX + Math.cos(rad) * hubRadius, centerY + Math.sin(rad) * hubRadius,
                centerX + Math.cos(rad) * rr, centerY + Math.sin(rad) * rr
            ));
        }
        return parts.join(" ");
    }

    function ringSvg(rr) {
        var parts = [];
        for (var k = 0; k < spokeCount; k++) {
            var a = -90 + (k * 360) / spokeCount;
            var b = a + 360 / spokeCount;
            var mid = ((a + b) / 2) * (Math.PI / 180);
            var ra = (a * Math.PI) / 180;
            var rb = (b * Math.PI) / 180;
            var sag = rr * 0.955;
            parts.push(
                "M " + (centerX + Math.cos(ra) * rr) + " " + (centerY + Math.sin(ra) * rr) +
                " Q " + (centerX + Math.cos(mid) * sag) + " " + (centerY + Math.sin(mid) * sag) +
                " " + (centerX + Math.cos(rb) * rr) + " " + (centerY + Math.sin(rb) * rr)
            );
        }
        return parts.join(" ");
    }

    readonly property int hotRings: Math.ceil(liveCount / 4)

    // Shape's Repeater support needs Item delegates, and ShapePath isn't one
    // (same constraint as the launcher's SpiderWeb) -- batch cold/hot rings
    // into two combined path strings instead of repeating ShapePath.
    readonly property string coldRingsSvg: {
        var parts = [];
        for (var i = 0; i < ringRatios.length; i++) {
            if (i < hotRings) continue;
            parts.push(ringSvg(ringRatios[i] * maxRadius));
        }
        return parts.join(" ");
    }
    readonly property string hotRingsSvg: {
        var parts = [];
        for (var i = 0; i < ringRatios.length; i++) {
            if (i >= hotRings) continue;
            parts.push(ringSvg(ringRatios[i] * maxRadius));
        }
        return parts.join(" ");
    }

    // A quick jitter on the lit chords -- like a plucked string -- on every
    // real keystroke / real denied attempt (pulseTick, bumped by LockView).
    // A geometric wobble, not an opacity/scale pulse.
    property real jitterX: 0
    SequentialAnimation {
        id: jitterAnim
        NumberAnimation { target: web; property: "jitterX"; to: -3; duration: 55 }
        NumberAnimation { target: web; property: "jitterX"; to: 3; duration: 55 }
        NumberAnimation { target: web; property: "jitterX"; to: -1.5; duration: 55 }
        NumberAnimation { target: web; property: "jitterX"; to: 0; duration: 55 }
    }
    onPulseTickChanged: jitterAnim.restart()

    // Spokes never jitter -- own Shape, no transform.
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: web.coldColor
            strokeWidth: 1
            PathSvg { path: web.coldSpokesSvg }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: web.hotColor
            strokeWidth: 1.8
            PathSvg { path: web.hotSpokesSvg }
        }
    }

    // All rings (chords) live here so the jitter is visible from the very
    // first keystroke, not just once a ring has fully "lit up" -- a ring only
    // turns hot every 4 characters and the innermost one is often hidden
    // under the hub, so gating the jitter on hotRingsSvg alone made it look
    // like nothing happened for the first few keystrokes.
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        transform: Translate { x: web.jitterX }

        ShapePath {
            fillColor: "transparent"
            strokeColor: web.coldColor
            strokeWidth: 1.1
            PathSvg { path: web.coldRingsSvg }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.rgba(web.hotColor.r, web.hotColor.g, web.hotColor.b, 0.45)
            strokeWidth: 1.5
            PathSvg { path: web.hotRingsSvg }
        }
    }
}
