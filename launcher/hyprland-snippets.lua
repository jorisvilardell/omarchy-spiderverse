
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Spiderverse launcher", "omarchy-spiderverse-launcher toggle")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

o.exec_on_start("omarchy-spiderverse-launcher start")

hl.layer_rule({ match = { namespace = "omarchy-spiderverse-launcher" }, no_anim = true, animation = "none" })
