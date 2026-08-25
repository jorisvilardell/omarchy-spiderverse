import QtQuick
import Quickshell
import Quickshell.Io

// Omarchy's own menu, as a model the web can render.
//
// The rows come from the same two files the stock menu reads:
// $OMARCHY_PATH/default/omarchy/omarchy-menu.jsonc and the user's extension.
// IDs are dotted, and the dots are the tree: `system.lock` sits under `system`.
//
// Rows that carry `provider` are backed by QML inside Omarchy's own menu plugin
// (the app list, the font picker). Those hand off to `omarchy-menu` rather than
// being reimplemented here — except `apps`, which this launcher already renders
// natively.
QtObject {
    id: catalog

    property string query: ""
    property string path: ""
    property int limit: 200

    property var entries: ({})
    property var guardResults: ({})

    readonly property string defaultMenuPath: (Quickshell.env("OMARCHY_PATH") || "/usr/share/omarchy") + "/default/omarchy/omarchy-menu.jsonc"
    readonly property string userMenuPath: Quickshell.env("HOME") + "/.config/omarchy/extensions/omarchy-menu.jsonc"

    readonly property var results: buildResults(entries, path, query, guardResults)
    readonly property string title: path === "" ? "Omarchy" : (entries[path] ? entries[path].label : path)

    // JSONC is JSON plus comments and trailing commas. Strings are tracked so a
    // `//` inside a value — a URL, say — is not mistaken for a comment.
    function parseJsonc(text) {
        let out = "";
        let inString = false;
        let escaped = false;
        let inLine = false;
        let inBlock = false;

        for (let i = 0; i < text.length; i++) {
            const ch = text[i];
            const next = text[i + 1];

            if (inLine) {
                if (ch === "\n") { inLine = false; out += ch; }
                continue;
            }
            if (inBlock) {
                if (ch === "*" && next === "/") { inBlock = false; i++; }
                continue;
            }
            if (inString) {
                out += ch;
                if (escaped) escaped = false;
                else if (ch === "\\") escaped = true;
                else if (ch === '"') inString = false;
                continue;
            }
            if (ch === '"') { inString = true; out += ch; continue; }
            if (ch === "/" && next === "/") { inLine = true; i++; continue; }
            if (ch === "/" && next === "*") { inBlock = true; i++; continue; }
            out += ch;
        }

        // Trailing commas.
        out = out.replace(/,(\s*[}\]])/g, "$1");
        return JSON.parse(out);
    }

    function merge(base, extension) {
        const merged = {};
        for (const id in base) merged[id] = base[id];
        for (const id in extension) {
            merged[id] = merged[id] ? Object.assign({}, merged[id], extension[id]) : extension[id];
        }
        return merged;
    }

    function parentOf(id) {
        const cut = String(id).lastIndexOf(".");
        return cut === -1 ? "" : id.slice(0, cut);
    }

    function kindOf(id, entry, source) {
        if (entry.action) return "action";
        if (entry.provider) return "provider";
        for (const other in source) {
            if (parentOf(other) === id) return "submenu";
        }
        return "action";
    }

    function visible(id, guards) {
        const verdict = guards[id];
        return verdict === undefined ? true : verdict;
    }

    function rowFor(id, entry, source, breadcrumb) {
        return {
            id: id,
            label: String(entry.label || id),
            description: breadcrumb || String(entry.description || ""),
            glyph: String(entry.icon || ""),
            glyphFont: String(entry.iconFont || ""),
            kind: kindOf(id, entry, source),
            action: entry.action || "",
            provider: entry.provider || "",
            checked: !!guardResults["checked:" + id]
        };
    }

    function breadcrumbFor(id, source) {
        const parts = [];
        let cursor = parentOf(id);
        while (cursor !== "") {
            const entry = source[cursor];
            parts.unshift(entry ? entry.label : cursor);
            cursor = parentOf(cursor);
        }
        return parts.join(" › ");
    }

    function matchScore(row, needle, aliases) {
        const label = row.label.toLowerCase();
        if (label === needle) return 0;
        if (label.indexOf(needle) === 0) return 1;
        if (label.indexOf(needle) !== -1) return 2;
        for (let i = 0; i < aliases.length; i++) {
            if (String(aliases[i]).toLowerCase().indexOf(needle) !== -1) return 3;
        }
        if (row.id.toLowerCase().indexOf(needle) !== -1) return 4;
        if (row.description.toLowerCase().indexOf(needle) !== -1) return 5;
        return -1;
    }

    // No query: the children of the current node, in file order. With a query:
    // every leaf in the whole tree, wherever it lives — same reach as typing in
    // the stock menu, with the breadcrumb saying where a hit came from.
    function buildResults(source, currentPath, value, guards) {
        const needle = String(value || "").trim().toLowerCase();
        const rows = [];

        if (!needle) {
            for (const id in source) {
                if (parentOf(id) !== currentPath) continue;
                if (!visible(id, guards)) continue;
                rows.push(rowFor(id, source[id], source, ""));
            }
            return rows.slice(0, limit);
        }

        const scored = [];
        for (const id in source) {
            if (!visible(id, guards)) continue;
            const entry = source[id];
            const row = rowFor(id, entry, source, breadcrumbFor(id, source));
            if (row.kind === "submenu") continue;
            const score = matchScore(row, needle, entry.aliases || []);
            if (score < 0) continue;
            row.score = score;
            scored.push(row);
        }

        scored.sort(function (first, second) {
            if (first.score !== second.score) return first.score - second.score;
            return first.label.localeCompare(second.label);
        });
        return scored.slice(0, limit);
    }

    function enter(row) {
        if (!row) return "stay";
        if (row.kind === "submenu") {
            path = row.id;
            return "descend";
        }
        if (row.kind === "provider") {
            // `apps` is this launcher's own surface; the caller handles it.
            if (row.provider === "apps") return "apps";
            Quickshell.execDetached(["omarchy-menu", "toggle", row.id]);
            return "close";
        }
        if (row.action) {
            Quickshell.execDetached(["bash", "-lc", row.action]);
            return "close";
        }
        return "stay";
    }

    function up() {
        if (path === "") return false;
        path = parentOf(path);
        return true;
    }

    // `when` and `checked` are shell conditions. Evaluating them one process at
    // a time would be dozens of spawns per open, so they go out as a single
    // script printing `id<TAB>0|1` per line, the way the stock menu batches them.
    function guardScript(source) {
        const lines = [];
        for (const id in source) {
            const entry = source[id];
            if (entry.when) {
                lines.push("if " + entry.when + " >/dev/null 2>&1; then echo '" + id + "\t1'; else echo '" + id + "\t0'; fi");
            }
            if (entry.checked) {
                lines.push("if " + entry.checked + " >/dev/null 2>&1; then echo 'checked:" + id + "\t1'; else echo 'checked:" + id + "\t0'; fi");
            }
        }
        return lines.join("\n");
    }

    function applyGuards(text) {
        const verdicts = {};
        const lines = String(text || "").split("\n");
        for (let i = 0; i < lines.length; i++) {
            const parts = lines[i].split("\t");
            if (parts.length !== 2) continue;
            verdicts[parts[0]] = parts[1] === "1";
        }
        guardResults = verdicts;
    }

    function refreshGuards() {
        const script = guardScript(entries);
        if (!script) { guardResults = {}; return; }
        guardProcess.command = ["bash", "-lc", script];
        guardProcess.running = true;
    }

    property var defaultFile: FileView {
        path: catalog.defaultMenuPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: catalog.rebuild()
    }

    property var userFile: FileView {
        path: catalog.userMenuPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: catalog.rebuild()
    }

    property var guardProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: catalog.applyGuards(text)
        }
    }

    function rebuild() {
        let base = {};
        let extension = {};
        try { base = parseJsonc(defaultFile.text()); } catch (error) { base = {}; }
        try { extension = parseJsonc(userFile.text()); } catch (error) { extension = {}; }
        entries = merge(base, extension);
        refreshGuards();
    }
}
