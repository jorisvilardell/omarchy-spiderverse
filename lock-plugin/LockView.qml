import QtQuick
import QtQuick.Effects
import "LockTheme.js" as Theme

// Spider-Verse lock screen. Public interface (properties/signals/functions)
// is unchanged from the packaged LockView.qml -- Service.qml (untouched,
// handles real PAM auth + session-lock protocol) instantiates this exact
// contract. Only the presentation below is new.
Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool unlocking: false
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property int spokeCount: 16
  readonly property int hubRadius: 150
  readonly property real centerX: width / 2
  readonly property real centerY: height * 0.545
  // *0.9 leaves a bit of breathing room above the web (it was nearly
  // touching the date text) instead of using every available pixel.
  readonly property real maxWebRadius: Math.max(260, Math.min(centerY - 40, height - centerY - 90, width / 2 - 60) * 0.9)
  readonly property bool errorState: failureMessage.length > 0
  readonly property int liveSpokes: Math.min(spokeCount, passwordInput.text.length)
  readonly property string username: "Axel"

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function fileUrl(path) {
    if (!path) return "";
    var encoded = String(path).split("/").map(encodeURIComponent).join("/");
    return "file://" + encoded + "?v=" + backgroundVersion;
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus();
  }

  function clearPassword() {
    passwordTextEdited("");
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return;
    syncingPasswordText = true;
    passwordInput.text = passwordText;
    syncingPasswordText = false;
  }

  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus);
  }
  Component.onCompleted: {
    syncPasswordText();
    if (inputEnabled) Qt.callLater(forcePasswordFocus);
  }

  // ── denied feedback: fires once on a real failureMessage transition ──
  property bool deniedFlash: false
  onFailureMessageChanged: {
    if (failureMessage.length > 0) {
      deniedFlash = true;
      deniedTimer.restart();
      hubShake.restart();
    }
  }
  Timer {
    id: deniedTimer
    interval: 900
    onTriggered: root.deniedFlash = false
  }

  // ── real feedback tick: bumped on every actually-typed character and on a
  // real denied attempt. Drives the web's hot-chord jitter below.
  // Backspace/clear does not re-trigger it.
  property int pulseTick: 0
  property int prevPasswordLength: 0
  onPasswordTextChanged: {
    syncPasswordText();
    if (passwordText.length > prevPasswordLength) pulseTick++;
    prevPasswordLength = passwordText.length;
  }
  onDeniedFlashChanged: if (deniedFlash) pulseTick++

  // ── live clock ──
  property var now: new Date()
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }
  readonly property string clockText: Qt.formatTime(now, "hh:mm")
  readonly property string dateText: Qt.formatDate(now, "dddd d MMMM").toUpperCase()

  // Real auth already succeeded once `unlocking` flips true (Service.qml
  // holds the still-secure surface up for ~450ms to let this play out before
  // actually releasing the session lock). There's no live desktop behind this
  // surface to cross-fade into (ext-session-lock-v1 hides it entirely until
  // the real unlock), so instead of fading to a blank void we sharpen/zoom
  // the same wallpaper up to its real, undimmed look and fade the UI chrome
  // away -- by the time the real unlock cuts the surface, this frame already
  // matches the plain desktop underneath, so the cut itself is invisible.
  Rectangle {
    anchors.fill: parent
    color: Theme.darkerBackground

    Image {
      id: wallpaper
      anchors.fill: parent
      source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
      transformOrigin: Item.Center
      scale: root.unlocking ? 1.05 : 1.0
      Behavior on scale { NumberAnimation { duration: 440; easing.type: Easing.OutCubic } }
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.status === Image.Ready
      blur: 1.0
      blurMax: 128
      blurMultiplier: root.unlocking ? 0 : 1.25
      contrast: root.unlocking ? 0 : -0.08
      Behavior on blurMultiplier { NumberAnimation { duration: 440; easing.type: Easing.OutCubic } }
      Behavior on contrast { NumberAnimation { duration: 440; easing.type: Easing.OutCubic } }
    }

    // Pushes the real wallpaper's own hues (often blue/teal) toward the
    // theme's indigo-violet so the web/hub/clock read against the same
    // palette as the mockup instead of competing with photo colors. Fades
    // away on unlock so the wallpaper's real colors show through, matching
    // the plain desktop.
    Rectangle {
      anchors.fill: parent
      opacity: root.unlocking ? 0 : 0.6
      Behavior on opacity { NumberAnimation { duration: 440; easing.type: Easing.OutCubic } }
      gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.lighterBackground }
        GradientStop { position: 0.55; color: Theme.background }
        GradientStop { position: 1.0; color: Theme.darkerBackground }
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus(); }
      onPositionChanged: root.wakeRequested()
    }

    // UI chrome (web/clock/hub) recedes and fades out on unlock, revealing
    // the sharpened wallpaper above instead of sitting on top of a cut.
    Item {
      id: chrome
      anchors.fill: parent
      transformOrigin: Item.Center
      scale: root.unlocking ? 0.94 : 1.0
      opacity: root.unlocking ? 0 : 1
      Behavior on scale { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

    LockWeb {
      anchors.fill: parent
      centerX: root.centerX
      centerY: root.centerY
      hubRadius: root.hubRadius
      maxRadius: root.maxWebRadius
      spokeCount: root.spokeCount
      liveCount: root.liveSpokes
      denied: root.deniedFlash
      pulseTick: root.pulseTick
    }

    // ── clock ──
    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      y: Math.max(40, root.centerY - root.maxWebRadius - 190)
      spacing: 10

      Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: clockMain.implicitWidth
        height: clockMain.implicitHeight

        Text {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: -4
          text: root.clockText
          color: Theme.cyan
          opacity: 0.6
          font.family: "Archivo Black"
          font.weight: Font.Black
          font.pixelSize: 92
        }
        Text {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 4
          text: root.clockText
          color: root.deniedFlash ? Theme.brightRed : Theme.red
          opacity: 0.6
          font.family: "Archivo Black"
          font.weight: Font.Black
          font.pixelSize: 92
        }
        Text {
          id: clockMain
          anchors.centerIn: parent
          text: root.clockText
          color: Theme.foreground
          font.family: "Archivo Black"
          font.weight: Font.Black
          font.pixelSize: 92
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.dateText
        color: Theme.darkForeground
        font.family: "JetBrains Mono"
        font.pixelSize: 15
        font.letterSpacing: 4
      }
    }

    // ── hub ──
    Item {
      id: hub
      x: root.centerX - width / 2
      y: root.centerY - height / 2
      width: root.hubRadius * 2
      height: root.hubRadius * 2

      property real shakeX: 0
      transform: Translate { x: hub.shakeX }
      SequentialAnimation {
        id: hubShake
        NumberAnimation { target: hub; property: "shakeX"; to: -10; duration: 55 }
        NumberAnimation { target: hub; property: "shakeX"; to: 9; duration: 55 }
        NumberAnimation { target: hub; property: "shakeX"; to: -6; duration: 55 }
        NumberAnimation { target: hub; property: "shakeX"; to: 4; duration: 55 }
        NumberAnimation { target: hub; property: "shakeX"; to: 0; duration: 55 }
      }

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Theme.lighterBackground
        opacity: 0.95
      }

      Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: root.deniedFlash ? Theme.red : (root.passwordText.length > 0 ? Theme.accent : Qt.rgba(0.29, 0.18, 0.48, 0.9))
        Behavior on border.color { ColorAnimation { duration: 120 } }
      }

      // Password field alone now -- the Spider-Man logo above used to live in
      // this Column but is now `heroSpider` (sibling, drawn above chrome) so
      // it can grow past the hub's bounds on unlock without disturbing this
      // layout.
      Item {
        anchors.horizontalCenter: parent.horizontalCenter
        // Below heroSpider's actual visible (rest-scaled) bottom edge, same
        // 14px gap the old Column spacing used.
        y: (heroSpider.y + heroSpider.height / 2 + (heroSpider.height * heroSpider.restScale) / 2 + 14) - hub.y
        width: Math.min(parent.width - 68, Math.max(120, passwordInput.implicitWidth + 24))
        height: 34

        TextInput {
            id: passwordInput
            anchors.centerIn: parent
            width: parent.width
            horizontalAlignment: TextInput.AlignHCenter
            activeFocusOnPress: true
            clip: true
            enabled: root.inputEnabled && !root.authenticatingPassword
            readOnly: root.authenticatingPassword
            echoMode: TextInput.Password
            passwordCharacter: "◆"
            passwordMaskDelay: 0
            color: root.deniedFlash ? Theme.red : Theme.accent
            selectionColor: Theme.selection
            selectedTextColor: Theme.foreground
            font.family: "Archivo Black"
            font.weight: Font.Black
            font.pixelSize: 20
            font.letterSpacing: 6
            cursorVisible: activeFocus && root.inputEnabled && !root.authenticatingPassword && text.length === 0
            cursorDelegate: Rectangle {
              width: 3
              height: 22
              color: Theme.accent
              visible: passwordInput.cursorVisible
              SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0; duration: 500 }
                NumberAnimation { to: 1; duration: 500 }
              }
            }

            onTextChanged: {
              if (!root.syncingPasswordText) root.passwordTextEdited(text);
              if (text.length > 0) root.wakeRequested();
              if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested();
            }

            onAccepted: {
              var submitted = root.passwordText;
              root.passwordTextEdited("");
              if (submitted.length > 0) root.submitPassword(submitted);
            }

            Keys.onPressed: function(event) {
              root.wakeRequested();
              if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
                root.passwordTextEdited("");
                event.accepted = true;
              }
            }
          }

        }
    }
    }

    // Spider-Man silhouette (spiderlogoblack.png, high-res so it stays sharp
    // once scaled up), drawn above chrome so it can grow well past the hub's
    // bounds. On unlock (real auth already succeeded, see `unlocking` above):
    // grows big first, then fades away as the wallpaper above finishes
    // sharpening -- so it hands off to the plain desktop instead of just
    // vanishing.
    Item {
      id: heroSpider
      // The item's own geometry (not a `scale` transform) is what MultiEffect
      // actually rasterizes at -- a small 157px item scaled up 6.5x via
      // `scale` stayed a 157px-resolution texture stretched, hence the
      // pixelation. Instead this is built at its full grown-in size (1024,
      // matching sourceSize below) and *shrunk* down to the resting hub size
      // via scale, so by the time it grows back to scale 1.0 it's showing
      // its native resolution, never upsampled.
      readonly property real restScale: (root.hubRadius * 1.05) / 1024
      x: root.centerX - width / 2
      y: (root.centerY - 38) - height / 2
      width: 1024
      height: 1024
      transformOrigin: Item.Center
      scale: restScale
      opacity: 1.0

      Image {
        id: heroSpiderSrc
        anchors.fill: parent
        source: "SpidermanLogo.png"
        fillMode: Image.PreserveAspectFit
        // Native file is 2500x3468 -- matches the item's grown-in size above.
        sourceSize.width: 1024
        sourceSize.height: 1024
        smooth: true
        visible: false
      }

      // Fixed px offsets here would scale down to near-nothing at rest
      // (restScale ~0.15) -- keep the glitch offset proportional to the
      // item's own size instead, same ~1.9% ratio the old 157px/3px combo had.
      readonly property real glitchOffset: width * (3 / 157.5)

      MultiEffect {
        anchors.fill: heroSpiderSrc
        source: heroSpiderSrc
        transform: Translate { x: -heroSpider.glitchOffset }
        colorization: 1.0
        colorizationColor: Theme.cyan
        opacity: 0.5
      }
      MultiEffect {
        anchors.fill: heroSpiderSrc
        source: heroSpiderSrc
        transform: Translate { x: heroSpider.glitchOffset }
        colorization: 1.0
        colorizationColor: root.deniedFlash ? Theme.brightRed : Theme.red
        opacity: 0.5
      }
      MultiEffect {
        anchors.fill: heroSpiderSrc
        source: heroSpiderSrc
        colorization: 1.0
        colorizationColor: root.deniedFlash ? Theme.red : (root.passwordText.length > 0 ? Theme.accent : Theme.foreground)
        Behavior on colorizationColor { ColorAnimation { duration: 150 } }
      }

      // Real PAM validation takes a moment (unavoidable, that's the actual
      // auth happening) -- without this the hub just sits frozen during that
      // gap and submitting a password reads as unresponsive. Pulse the spider
      // gently while `authenticatingPassword` is genuinely true so the wait
      // reads as "working" instead of "stuck". Never runs during `unlocking`
      // (auth already resolved false by then, see Service.qml).
      SequentialAnimation {
        id: authPulse
        loops: Animation.Infinite
        running: root.authenticatingPassword
        onStopped: heroSpider.opacity = 1.0
        NumberAnimation { target: heroSpider; property: "opacity"; to: 0.55; duration: 420; easing.type: Easing.InOutQuad }
        NumberAnimation { target: heroSpider; property: "opacity"; to: 1.0; duration: 420; easing.type: Easing.InOutQuad }
      }

      NumberAnimation {
        id: heroGrowAnim
        target: heroSpider
        property: "scale"
        to: 1.0
        duration: 300
        easing.type: Easing.OutQuint
      }
      NumberAnimation {
        id: heroFadeAnim
        target: heroSpider
        property: "opacity"
        to: 0
        duration: 260
        easing.type: Easing.InQuad
      }
      // Starts a bit before the grow finishes (200ms, grow ends at 300ms) so
      // there's no beat where it just sits at max size doing nothing -- ends
      // at 460ms total.
      Timer { id: heroFadeDelay; interval: 200; onTriggered: heroFadeAnim.start() }

      Connections {
        target: root
        function onUnlockingChanged() {
          if (root.unlocking) {
            heroGrowAnim.start();
            heroFadeDelay.start();
          } else {
            heroGrowAnim.stop();
            heroFadeDelay.stop();
            heroFadeAnim.stop();
            heroSpider.scale = heroSpider.restScale;
            heroSpider.opacity = 1.0;
          }
        }
      }
    }

    // ── access denied flash ──
    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      y: root.centerY + root.hubRadius + 46
      width: deniedMain.implicitWidth
      height: deniedMain.implicitHeight
      opacity: root.deniedFlash ? 1 : 0
      scale: root.deniedFlash ? 1 : 0.85
      Behavior on opacity { NumberAnimation { duration: 90 } }
      Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 3 } }

      Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -3
        text: "ACCESS DENIED"
        color: Theme.cyan
        opacity: 0.8
        font.family: "Archivo Black"
        font.weight: Font.Black
        font.pixelSize: 30
        font.letterSpacing: 2
      }
      Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 3
        text: "ACCESS DENIED"
        color: Theme.brightRed
        opacity: 0.8
        font.family: "Archivo Black"
        font.weight: Font.Black
        font.pixelSize: 30
        font.letterSpacing: 2
      }
      Text {
        id: deniedMain
        anchors.centerIn: parent
        text: "ACCESS DENIED"
        color: Theme.foreground
        font.family: "Archivo Black"
        font.weight: Font.Black
        font.pixelSize: 30
        font.letterSpacing: 2
      }
    }

  }
}
