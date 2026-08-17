# Spiderverse lock screen

Presentational layer for Omarchy's Quattro lock screen, restyled with a
radial web, RGB-split clock, and a growing Spider-Man mark on unlock.

## Why `Service.qml` isn't in this repo

Omarchy's lock screen isn't a separate `hyprlock` process on Quattro -- it's
a *service* plugin of `omarchy-shell`, split into two files:

- `Service.qml` -- the real logic: PAM authentication, the
  `ext-session-lock-v1` protocol, retry/lockout handling, idle/wake. **Not
  touched by this repo, ever.**
- `LockView.qml` (+ `LockWeb.qml`, `LockTheme.js`, `SpidermanLogo.png`) --
  the purely visual layer. Receives state via properties
  (`authenticatingPassword`, `failureMessage`, `passwordText`, ...) and emits
  signals (`submitPassword`, ...) back to `Service.qml`. **This is what this
  repo replaces.**

The only supported way to customize the lock screen beyond colors is
`omarchy plugin clone`, which forks *both* files together. Shipping a copy of
`Service.qml` in a git repo would freeze it at whatever Omarchy version it
was cloned from -- it would silently stop receiving upstream security fixes.
So `install.sh` clones fresh from *your own* Omarchy install every time, and
only overlays the four presentational files above onto that clone.

## Install

```bash
./install.sh
omarchy restart shell
```

## Try it safely

The lock plugin exposes a preview mode that never engages real
authentication (`inputEnabled: false`):

```bash
qs -p /usr/share/omarchy/shell ipc call lock preview
qs -p /usr/share/omarchy/shell ipc call lock hidePreview
```

Test a real unlock (typing, wrong password, etc.) yourself with `SUPER+L` --
keep a spare TTY (`Ctrl+Alt+F2`) or SSH session handy the first time, same as
you would for any lock screen customization.

## Re-syncing after an Omarchy update

Since `Service.qml` is a fork, it won't auto-update. If you want the latest
upstream fixes, remove the cloned plugin and re-run `install.sh` to get a
fresh clone + reapply the theme files.
