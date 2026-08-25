
-- Mirrors Omarchy's own layout: SUPER+SPACE is the menu, SUPER+ALT+SPACE the
-- app launcher. Both are rendered on the web here.
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Spiderverse menu", "omarchy-spiderverse-launcher menu")
o.bind("SUPER + ALT + SPACE", "Spiderverse launcher", "omarchy-spiderverse-launcher toggle")

o.exec_on_start("omarchy-spiderverse-launcher start")

hl.layer_rule({ match = { namespace = "omarchy-spiderverse-launcher" }, no_anim = true, animation = "none" })
