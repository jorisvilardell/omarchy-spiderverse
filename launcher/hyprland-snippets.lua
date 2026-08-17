-- Spiderverse launcher -- Hyprland (Lua config) snippets.
-- Not applied automatically by install.sh: copy the bits you want into your
-- own hyprland.lua / bindings.lua / autostart.lua, adjusting keys if they
-- collide with something you already use.

-- bindings.lua ---------------------------------------------------------
-- Replaces the native SUPER + SPACE app launcher with this one; moves
-- Omarchy's own root menu to SUPER + ALT + SPACE so it's still reachable.
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Spiderverse launcher", "omarchy-spiderverse-launcher toggle")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

-- autostart.lua ---------------------------------------------------------
-- Optional: pre-warms the launcher's Quickshell daemon on login so the
-- first SUPER + SPACE press isn't paying its cold-start cost.
o.exec_on_start("omarchy-spiderverse-launcher start")

-- hyprland.lua ---------------------------------------------------------
-- Optional: kills the compositor's own fade-in/out animation for the
-- launcher's layer-shell surface, since it renders its own open/close
-- treatment and the two were fighting/lagging together.
hl.layer_rule({ match = { namespace = "omarchy-spiderverse-launcher" }, no_anim = true, animation = "none" })
