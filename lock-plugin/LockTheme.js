.pragma library

// Palette fixe, recopiee depuis ~/.config/omarchy/themes/spiderverse/colors.toml.
// Copie independante (pas d'import inter-process du launcher): ce plugin
// tourne dans le process omarchy-shell, toujours actif, distinct du process
// autonome du launcher -- le coupler a ce dernier le rendrait fragile si ce
// dossier est deplace ou supprime. Meme choix que le launcher: figee, pas
// derivee du theme Omarchy actif.

var background = "#160a2e";
var darkBackground = "#0d0620";
var darkerBackground = "#070312";
var lighterBackground = "#2d1b4e";

var foreground = "#f2e9ff";
var darkForeground = "#9a86c2";
var lightForeground = "#d8c9f5";
var brightForeground = "#ffffff";

var accent = "#ff2d95";
var selection = "#4a2e7a";
var muted = "#6b5390";

var red = "#df1f2d";
var yellow = "#ffd23f";
var orange = "#ff6b4a";
var green = "#3ef2a0";
var cyan = "#00e5ff";
var blue = "#447bbe";
var magenta = "#ff2d95";
var brown = "#8a5a6b";

var brightRed = "#f4143c";
var brightCyan = "#4de8ff";
