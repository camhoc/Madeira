import Foundation

/// steam-layout-import (Nov 27): turns a Steam Input layout file (.vdf, the "controller_mappings" format
/// that community layouts and Valve's own templates use) into the per-game keyboard-and-mouse binds table
/// (LibraryEntry.controllerBinds). Madeira does not run Steam Input (the Steam client inside it cannot
/// load SDL3.dll, status c000007b), so this reads the file itself and keeps only what the binds table can
/// express: face buttons, bumpers, triggers, D-pad, Start/Select, stick clicks, a stick as WASD or the
/// arrow keys, and the right stick as the mouse. Gyro, action layers, mode shifts, radial menus, touch
/// pads and xinput_button bindings are skipped and named in the result. Only "Default" preset bindings
/// of sources marked active are read. Off: env.MADEIRA_STEAM_LAYOUT_IMPORT = 0 hides the button.
enum SteamLayoutImport {
    static let on = MadeiraConfig.flag("MADEIRA_STEAM_LAYOUT_IMPORT")

    struct Result {
        var binds: [String: ControlAction]
        var skipped: [String]
        /// The preset the bindings came from ("Default" when the file has one).
        var preset: String
    }

    // MARK: VDF text

    struct Entry {
        let key: String
        let text: String?
        let block: [Entry]?
    }

    private enum Token { case string(String), open, close }

    private static func tokens(_ text: String) -> [Token] {
        let s = Array(text.unicodeScalars)
        var out: [Token] = []
        var i = 0
        while i < s.count {
            let c = s[i]
            if c == "\u{FEFF}" || c.properties.isWhitespace { i += 1; continue }
            if c == "/", i + 1 < s.count, s[i + 1] == "/" {
                while i < s.count, s[i] != "\n" { i += 1 }
                continue
            }
            if c == "{" { out.append(.open); i += 1; continue }
            if c == "}" { out.append(.close); i += 1; continue }
            var word = String.UnicodeScalarView()
            if c == "\"" {
                i += 1
                while i < s.count, s[i] != "\"" {
                    if s[i] == "\\", i + 1 < s.count {
                        i += 1
                        switch s[i] {
                        case "n": word.append("\n")
                        case "t": word.append("\t")
                        default: word.append(s[i])
                        }
                    } else {
                        word.append(s[i])
                    }
                    i += 1
                }
                i += 1   // the closing quote
            } else {
                while i < s.count, !s[i].properties.isWhitespace, s[i] != "{", s[i] != "}", s[i] != "\"" {
                    word.append(s[i]); i += 1
                }
            }
            out.append(.string(String(word)))
        }
        return out
    }

    static func parse(_ text: String) -> [Entry] {
        let toks = tokens(text)
        var pos = 0
        func block(_ depth: Int) -> [Entry] {
            var items: [Entry] = []
            while pos < toks.count {
                switch toks[pos] {
                case .close:
                    pos += 1
                    return items
                case .open:
                    pos += 1   // a brace with no key: read its content into this level
                    if depth < 40 { items += block(depth + 1) }
                case .string(let key):
                    pos += 1
                    guard pos < toks.count else { return items }
                    switch toks[pos] {
                    case .open:
                        pos += 1
                        items.append(Entry(key: key, text: nil, block: depth < 40 ? block(depth + 1) : []))
                    case .string(let value):
                        pos += 1
                        items.append(Entry(key: key, text: value, block: nil))
                    case .close:
                        break   // a key with no value; the close is handled by the loop
                    }
                }
            }
            return items
        }
        return block(0)
    }

    private static func value(_ e: [Entry], _ key: String) -> String? {
        e.first { $0.key.lowercased() == key && $0.text != nil }?.text
    }
    private static func child(_ e: [Entry], _ key: String) -> [Entry]? {
        e.first { $0.key.lowercased() == key && $0.block != nil }?.block
    }

    // MARK: bindings

    /// Steam's key names to Windows virtual-key codes (the shifts, controls and alts use the generic codes
    /// PadBindings.template uses). nil for a key this table does not have.
    static func virtualKey(_ name: String) -> Int32? {
        let n = name.uppercased()
        if n.count == 1, let u = n.unicodeScalars.first, (u.value >= 0x30 && u.value <= 0x39) || (u.value >= 0x41 && u.value <= 0x5A) {
            return Int32(u.value)
        }
        let table: [String: Int32] = [
            "SPACE": 0x20, "RETURN": 0x0D, "ENTER": 0x0D, "ESCAPE": 0x1B, "TAB": 0x09, "BACKSPACE": 0x08,
            "DELETE": 0x2E, "INSERT": 0x2D, "HOME": 0x24, "END": 0x23, "PAGE_UP": 0x21, "PAGE_DOWN": 0x22,
            "LEFT_SHIFT": 0x10, "RIGHT_SHIFT": 0x10, "LEFT_CONTROL": 0x11, "RIGHT_CONTROL": 0x11,
            "LEFT_ALT": 0x12, "RIGHT_ALT": 0x12, "CAPSLOCK": 0x14, "CAPS_LOCK": 0x14,
            "UP_ARROW": 0x26, "DOWN_ARROW": 0x28, "LEFT_ARROW": 0x25, "RIGHT_ARROW": 0x27,
            "COMMA": 0xBC, "PERIOD": 0xBE, "FORWARD_SLASH": 0xBF, "BACK_SLASH": 0xDC, "SEMICOLON": 0xBA,
            "SINGLE_QUOTE": 0xDE, "LEFT_BRACKET": 0xDB, "RIGHT_BRACKET": 0xDD, "DASH": 0xBD, "EQUALS": 0xBB,
            "BACK_TICK": 0xC0,
        ]
        if let v = table[n] { return v }
        if n.hasPrefix("F"), let k = Int(n.dropFirst()), (1...12).contains(k) { return Int32(0x6F + k) }
        return nil
    }

    /// "key_press W, Jump" / "mouse_button LEFT" / "mouse_wheel SCROLL_UP, Next" as an action; nil for the rest.
    static func action(_ binding: String) -> ControlAction? {
        let head = binding.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? ""
        let parts = head.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
        guard parts.count >= 2 else { return nil }
        let arg = parts[1].uppercased()
        switch parts[0].lowercased() {
        case "key_press": return virtualKey(arg).map { ControlAction.key($0) }
        case "mouse_button":
            switch arg {
            case "LEFT": return .mouseLeft
            case "RIGHT": return .mouseRight
            case "MIDDLE": return .mouseMiddle
            default: return nil
            }
        case "mouse_wheel":
            switch arg {
            case "SCROLL_UP": return .scrollUp
            case "SCROLL_DOWN": return .scrollDown
            default: return nil
            }
        default: return nil
        }
    }

    /// The first usable binding of an input: its Full_Press, else Long_Press, else Double_Press activator.
    private static func firstBinding(_ input: [Entry]) -> String? {
        guard let activators = child(input, "activators") else { return nil }
        for kind in ["full_press", "long_press", "double_press"] {
            for a in activators where a.key.lowercased() == kind {
                if let b = a.block, let bindings = child(b, "bindings"), let text = value(bindings, "binding") { return text }
            }
        }
        return nil
    }

    // MARK: layout to binds

    /// nil when the text has no "controller_mappings" block.
    static func convert(_ text: String) -> Result? {
        let tree = parse(text)
        guard let mappings = child(tree, "controller_mappings") else { return nil }
        var groups: [String: [Entry]] = [:]
        for e in mappings where e.key.lowercased() == "group" {
            if let b = e.block, let id = value(b, "id") { groups[id] = b }
        }
        let presets = mappings.filter { $0.key.lowercased() == "preset" }.compactMap { $0.block }
        guard let preset = presets.first(where: { (value($0, "name") ?? "").lowercased() == "default" }) ?? presets.first,
              let sources = child(preset, "group_source_bindings") else { return nil }

        var binds: [String: ControlAction] = [:]
        var skipped: [String] = []
        var xinputLeft = 0
        func put(_ name: String, _ binding: String?) {
            guard let binding = binding else { return }
            if let a = action(binding) { binds[name] = a }
            else if binding.lowercased().hasPrefix("xinput_button") { xinputLeft += 1 }   // the template already does this
            else { skipped.append("\(name): \(binding)") }
        }
        let wasd: [ControlAction?] = [ControlAction.key(0x57), ControlAction.key(0x44), ControlAction.key(0x53), ControlAction.key(0x41)]
        let arrows: [ControlAction?] = [ControlAction.key(0x26), ControlAction.key(0x27), ControlAction.key(0x28), ControlAction.key(0x25)]

        for entry in sources {
            guard let state = entry.text else { continue }
            let words = state.lowercased().split(separator: " ").map(String.init)
            // "active" only: "inactive" and "active modeshift" (a layer on top of a base binding) are left out.
            guard words.count == 2, words[1] == "active", let group = groups[entry.key] else { continue }
            let source = words[0]
            let mode = (value(group, "mode") ?? "").lowercased()
            var inputs: [String: [Entry]] = [:]
            for e in child(group, "inputs") ?? [] { if let b = e.block { inputs[e.key.lowercased()] = b } }
            func binding(_ name: String) -> String? { inputs[name].flatMap(firstBinding) }

            switch source {
            case "button_diamond":
                for (n, t) in [("button_a", "A"), ("button_b", "B"), ("button_x", "X"), ("button_y", "Y")] { put(t, binding(n)) }
            case "switch":
                // button_escape is Start (Escape in Valve's own template), button_menu is Select.
                for (n, t) in [("left_bumper", "LB"), ("right_bumper", "RB"), ("button_escape", "Menu"), ("button_menu", "View")] { put(t, binding(n)) }
            case "left_trigger", "right_trigger":
                put(source == "left_trigger" ? "LT" : "RT", binding("edge") ?? binding("click"))
            case "dpad":
                for (n, t) in [("dpad_north", "D↑"), ("dpad_south", "D↓"), ("dpad_west", "D←"), ("dpad_east", "D→")] { put(t, binding(n)) }
            case "joystick", "right_joystick":
                let stick = source == "joystick" ? "LS" : "RS"
                if mode == "dpad" {
                    let keys = ["dpad_north", "dpad_east", "dpad_south", "dpad_west"].map { binding($0).flatMap(action) }
                    if keys == wasd { binds[stick] = .joystickWASD }
                    else if keys == arrows { binds[stick] = .joystickArrows }
                    else { skipped.append("\(stick): keys other than WASD or the arrows") }
                } else if (mode == "joystick_mouse" || mode == "mouse_joystick") && stick == "RS" {
                    binds["RS"] = ControlAction.none   // .none on the right stick means: the mouse
                } else {
                    skipped.append("\(stick): \(mode.isEmpty ? "unknown" : mode) mode")
                }
                put(stick == "LS" ? "L3" : "R3", binding("click"))
            default:
                skipped.append("\(source): \(mode.isEmpty ? "unknown" : mode) mode")
            }
        }
        // Modern layouts keep the bumpers, Start and Select in the preset's own switch_bindings block, not in a
        // "switch" group. Used for whichever of the four the groups did not bind.
        if let sw = child(preset, "switch_bindings"), let list = child(sw, "bindings") {
            for (n, t) in [("left_bumper", "LB"), ("right_bumper", "RB"), ("button_escape", "Menu"), ("button_menu", "View")] where binds[t] == nil {
                if let text = list.first(where: { $0.key.lowercased() == n })?.text { put(t, text) }
            }
        }
        if xinputLeft > 0 { skipped.append("\(xinputLeft) xinput_button binding\(xinputLeft == 1 ? "" : "s") left to the defaults") }
        return Result(binds: binds, skipped: skipped, preset: value(preset, "name") ?? "first preset")
    }

    /// A short line for the page: what was applied and what was left out.
    static func summary(_ r: Result) -> String {
        var line = "Imported \(r.binds.count) binding\(r.binds.count == 1 ? "" : "s") from preset \"\(r.preset)\"."
        if !r.skipped.isEmpty { line += " Skipped \(r.skipped.count): " + r.skipped.prefix(4).joined(separator: "; ") + (r.skipped.count > 4 ? "…" : "") + "." }
        return line
    }
}
