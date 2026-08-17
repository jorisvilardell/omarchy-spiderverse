import QtQuick
import QtQuick.Shapes
import "SpiderverseTheme.js" as Theme

// Comic-panel card: two opposite corners cut off (mirrors the mockup's CSS
// clip-path), initials tinted by app category, active state pops with a
// scale + accent border + a short "vibe" jitter.
Item {
    id: card

    property string label: ""
    property string initialsText: ""
    property url iconSource: ""
    property color tint: Theme.accent
    property bool active: false

    signal activated()
    signal requested()

    readonly property int cut: 13
    property real cardSize: active ? 90 : 84

    implicitWidth: cardSize
    implicitHeight: cardSize

    Behavior on cardSize { NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 3 } }

    // "Vibe" jitter: a quick back-and-forth nudge played once when a card
    // becomes active (ported from the mockup's sv-vibe keyframes).
    property real jitterX: 0
    property real jitterY: 0
    SequentialAnimation {
        id: vibe
        NumberAnimation { target: card; property: "jitterX"; to: -3; duration: 90 }
        NumberAnimation { target: card; property: "jitterX"; to: 3; duration: 90 }
        NumberAnimation { target: card; property: "jitterX"; to: 0; duration: 90 }
    }
    onActiveChanged: if (active) vibe.start()

    transform: Translate { x: card.jitterX; y: card.jitterY }

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: card.active ? Theme.selection : Theme.darkerBackground
            strokeColor: card.active ? Theme.accent : Theme.lighterBackground
            strokeWidth: 1

            startX: 0; startY: 0
            PathLine { x: card.width - card.cut; y: 0 }
            PathLine { x: card.width; y: card.cut }
            PathLine { x: card.width; y: card.height }
            PathLine { x: card.cut; y: card.height }
            PathLine { x: 0; y: card.height - card.cut }
            PathLine { x: 0; y: 0 }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 4
        width: parent.width - 12

        // Real app icon when one resolves; RGB-split initials (CSS
        // text-shadow has no QML equivalent, faked with offset duplicates)
        // as a fallback for apps with no icon.
        Item {
            id: iconStack
            width: parent.width
            height: 34

            readonly property bool imageVisible: String(card.iconSource).length > 0 && iconImage.status !== Image.Error

            Image {
                id: iconImage
                anchors.centerIn: parent
                width: 32
                height: 32
                source: card.iconSource
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                visible: iconStack.imageVisible
            }

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: card.active ? -2 : 0
                text: card.initialsText
                color: Theme.cyan
                opacity: (card.active && !iconStack.imageVisible) ? 0.75 : 0
                font.family: "Archivo Black"
                font.pixelSize: 22
                visible: !iconStack.imageVisible
            }
            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: card.active ? 2 : 0
                text: card.initialsText
                color: Theme.red
                opacity: (card.active && !iconStack.imageVisible) ? 0.75 : 0
                font.family: "Archivo Black"
                font.pixelSize: 22
                visible: !iconStack.imageVisible
            }
            Text {
                id: initialsLabel
                anchors.centerIn: parent
                text: card.initialsText
                color: card.active ? Theme.foreground : card.tint
                font.family: "Archivo Black"
                font.pixelSize: 22
                visible: !iconStack.imageVisible
            }
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: card.label
            color: Theme.darkForeground
            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.letterSpacing: 1
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: card.active ? card.activated() : card.requested()
    }
}
