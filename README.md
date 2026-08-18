# Spiderverse for Omarchy

Across-the-Spider-Verse-inspired radial app launcher and lock screen for
[Omarchy](https://omarchy.org) (Quattro). Two independent pieces -- take
whichever one you want. Matching theme: [omarchy-spiderverse-theme](https://github.com/axelfrache/omarchy-spiderverse-theme).

## Preview

![lock screen](lock-plugin/preview.png)

## Launcher

```bash
git clone https://github.com/axelfrache/omarchy-spiderverse.git
./omarchy-spiderverse/launcher/install.sh
```

Standalone Quickshell app, no system hooks. See
[`launcher/`](launcher/) for keybindings and details.

## Lock screen

```bash
./omarchy-spiderverse/lock-plugin/install.sh
```

Clones Omarchy's real lock service and overlays this theme on top. Read
[`lock-plugin/README.md`](lock-plugin/README.md) first -- it explains what
gets touched.

## Requirements

- Omarchy Quattro (the `omarchy-shell` / Quickshell-based version)
- `qs` (Quickshell CLI), which Omarchy already ships
