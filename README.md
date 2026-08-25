# Spiderverse for Omarchy

Across-the-Spider-Verse-inspired radial app launcher and lock screen for
[Omarchy](https://omarchy.org) (Quattro). Two independent pieces -- take
whichever one you want. Matching theme: [omarchy-spiderverse-theme](https://github.com/axelfrache/omarchy-spiderverse-theme).

## Preview

![app launcher](launcher/preview.png)
![lock screen](lock-plugin/preview.png)

## Install everything

Theme + launcher + lock screen in one go:

```bash
curl -fsSL https://raw.githubusercontent.com/axelfrache/omarchy-spiderverse/main/install.sh | bash
```

Or pick just the pieces you want below.

## Launcher

```bash
curl -fsSL https://raw.githubusercontent.com/axelfrache/omarchy-spiderverse/main/launcher/install.sh | bash
```

Standalone Quickshell app, no system hooks. See
[`launcher/`](launcher/) for keybindings and details.

## Lock screen

```bash
curl -fsSL https://raw.githubusercontent.com/axelfrache/omarchy-spiderverse/main/lock-plugin/install.sh | bash
```

Clones Omarchy's real lock service and overlays this theme on top. Read
[`lock-plugin/README.md`](lock-plugin/README.md) first -- it explains what
gets touched.

Prefer to read the scripts before running them? Clone the repo instead and
run `./install.sh`, `./launcher/install.sh`, or `./lock-plugin/install.sh`
locally -- same scripts, no piping to bash.

## Requirements

- Omarchy Quattro (the `omarchy-shell` / Quickshell-based version)
- `qs` (Quickshell CLI), which Omarchy already ships

## Uninstalling

```bash
./uninstall.sh                 # both
./lock-plugin/uninstall.sh     # lock screen only
./launcher/uninstall.sh        # launcher only
```

Removing the lock clone takes more than deleting its directory: enabling a
clone puts its source id into `disabledPlugins`, so `omarchy.lock` would stay
off and the session would end up with no lock screen at all. The script
disables the clone, deletes it, then re-enables `omarchy.lock`.

Keybindings are never touched, in either direction — you copied them in from
`launcher/hyprland-snippets.lua`, so you take them out. The uninstaller prints
the stock ones.

## Theme-bound install (optional)

Everything above is permanent: once the lock plugin is cloned and the launcher
sits in `~/.local/bin`, they stay whatever Omarchy theme is active. Switch to
Tokyo Night and you still get the Spiderverse lock screen.

`omatheme.toml` at the root of this repo describes the same files as a *theme
payload*. [omatheme](https://github.com/jorisvilardell/omatheme) reads it and
copies them into a theme's directory, so they follow that theme:

```bash
omatheme install https://github.com/axelfrache/omarchy-spiderverse-theme
omatheme install https://github.com/axelfrache/omarchy-spiderverse
omatheme apply spiderverse
```

The first URL is a theme and is handed to Omarchy; the second is this repo and
is grafted onto the theme its manifest names. To link the launcher and lock
screen to a different theme, name it:

```bash
omatheme install https://github.com/axelfrache/omarchy-spiderverse --theme kanagawa
```

Selecting the theme then installs the launcher and overlays the lock screen,
and selecting any other theme restores Omarchy's own. Bind the launcher once
and it follows the theme from then on:

```lua
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Menu", "omatheme launcher menu")
o.bind("SUPER + ALT + SPACE", "Apps", "omatheme launcher apps")
```

Someone who wants the theme but only one of the two pieces switches the other
off in `~/.config/omatheme/config.toml`:

```toml
[themes.spiderverse]
launcher = false
```

Nothing about the one-shot path changes, and the theme repo stays a plain
theme — the payload is described here, where the sources are maintained.

## Repository layout

```
launcher/
  quickshell/          the Quickshell app
  bin/                 the helper script
  hyprland-snippets.lua
  install.sh  uninstall.sh
lock-plugin/
  qml/                 LockView.qml, LockWeb.qml, LockTheme.js, SpidermanLogo.png
  install.sh  uninstall.sh
omatheme.toml          payload manifest, for the theme-bound path
install.sh  uninstall.sh
```

`lock-plugin/qml/` holds only the presentational layer. `Service.qml` — PAM,
`ext-session-lock-v1`, retry and lockout — is never in this repo: both install
paths clone it fresh from your own Omarchy, so it always tracks upstream.
