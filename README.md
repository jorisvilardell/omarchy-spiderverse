# Spiderverse for Omarchy

Across-the-Spider-Verse-inspired look for [Omarchy](https://omarchy.org)
(Quattro): a theme, a radial app launcher, and an interactive lock screen.
Three independent pieces -- take whichever ones you want.

| Folder | What it is | Risk |
|---|---|---|
| [`theme/`](theme/) | Colors, background, window border/animation tweaks | None -- just an Omarchy theme |
| [`launcher/`](launcher/) | Standalone radial app launcher (Quickshell) | None -- self-contained, no system hooks |
| [`lock-plugin/`](lock-plugin/) | Restyled lock screen | Read its README first -- it clones Omarchy's real auth logic |

Each folder has its own README and `install.sh` (theme is a plain copy, no
script needed). Start with `theme/`, then add the others if you want them.

## Screenshots

Not included here -- run `omarchy-spiderverse-launcher toggle` or
`qs -p /usr/share/omarchy/shell ipc call lock preview` after installing to
see them live.

## Requirements

- Omarchy Quattro (the `omarchy-shell` / Quickshell-based version -- this
  won't apply to older hyprlock-based Omarchy setups)
- `qs` (Quickshell CLI) available, which Omarchy already ships
