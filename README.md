# Spiderverse for Omarchy

Across-the-Spider-Verse-inspired look for [Omarchy](https://omarchy.org)
(Quattro): a radial app launcher and an interactive lock screen. Two
independent pieces -- take whichever one you want.

The matching color theme lives in its own repo,
[omarchy-spiderverse-theme](https://github.com/<you>/omarchy-spiderverse-theme) -- Omarchy's
`omarchy theme install <url>` clones a repo directly as the theme folder and
expects the palette files at its root, which doesn't work from inside a
monorepo subfolder.

| Folder | What it is | Risk |
|---|---|---|
| [`launcher/`](launcher/) | Standalone radial app launcher (Quickshell) | None -- self-contained, no system hooks |
| [`lock-plugin/`](lock-plugin/) | Restyled lock screen | Read its README first -- it clones Omarchy's real auth logic |

Each folder has its own README and `install.sh`.

## Screenshots

Not included here -- run `omarchy-spiderverse-launcher toggle` or
`qs -p /usr/share/omarchy/shell ipc call lock preview` after installing to
see them live.

## Requirements

- Omarchy Quattro (the `omarchy-shell` / Quickshell-based version -- this
  won't apply to older hyprlock-based Omarchy setups)
- `qs` (Quickshell CLI) available, which Omarchy already ships
