import Foundation

/// Reads and checks a Winlator-style .wcp profile.json. Pure parsing and path checks, no file writes.
/// DRAFT: not compiled. Off switch: env.MADEIRA_WCP_IMPORT = 0.
struct WCPProfile {
    struct Entry { let source: String; let target: String }
    let type: String, versionName: String, versionCode: Int, files: [Entry]

    /// Component types that make sense on iOS (Windows DLLs, FEX, Wine files).
    /// v1 installs only these two (Madeira's existing d3d11 = dxvk and d3d12 = vkd3d routes). "vkd3d-proton" counts as "vkd3d".
    static let allowedTypes: Set<String> = ["dxvk", "vkd3d"]
    /// Android only. Refused with a plain message.
    static let refusedTypes: Set<String> = ["turnip", "adreno", "mali", "wrapper", "box64", "wowbox64", "bionic-box64"]

    enum Failure: Error, LocalizedError { case notJSON, missing(String), androidOnly(String), unknownType(String), badPath(String) }

    static func message(_ e: Error) -> String {
        switch e {
        case Failure.notJSON: return "This package's profile.json can't be read."
        case Failure.missing(let k): return "This package's profile.json has no \(k)."
        case Failure.androidOnly(let t): return "\(t) packages are for Android and can't be used here."
        case Failure.unknownType(let t): return "Madeira can only use DXVK and vkd3d-proton packages for now, not \(t)."
        case Failure.badPath(let p): return "This package names a file path that isn't allowed: \(p)."
        default: return "The package could not be imported."
        }
    }

    static var enabled: Bool { MadeiraConfig.flag("MADEIRA_WCP_IMPORT") }

    static func parse(_ data: Data) throws -> WCPProfile {
        guard let o = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw Failure.notJSON }
        guard var type = (o["type"] as? String)?.lowercased() else { throw Failure.missing("type") }
        if type == "vkd3d-proton" { type = "vkd3d" }
        if refusedTypes.contains(type) { throw Failure.androidOnly(type) }
        guard allowedTypes.contains(type) else { throw Failure.unknownType(type) }
        guard let list = o["files"] as? [[String: Any]], !list.isEmpty else { throw Failure.missing("files") }
        var entries: [Entry] = []
        for f in list {
            guard let s = f["source"] as? String, let t = f["target"] as? String else { throw Failure.missing("files.source/target") }
            guard safe(s), safe(strip(t)) else { throw Failure.badPath(t) }
            entries.append(Entry(source: s, target: t))
        }
        return WCPProfile(type: type, versionName: o["versionName"] as? String ?? "?", versionCode: o["versionCode"] as? Int ?? 0, files: entries)
    }

    /// Known placeholders: ${system32}, ${syswow64} (seen in a real DXVK package), ${libdir}, ${sharedir} (GameNative PR #1740).
    static let roots = ["${system32}", "${syswow64}", "${libdir}", "${sharedir}"]
    /// Target without its placeholder; unknown placeholder or none -> keeps "$" so safe() refuses it.
    static func strip(_ t: String) -> String {
        for r in roots where t.hasPrefix(r + "/") { return String(t.dropFirst(r.count + 1)) }
        return t.hasPrefix("$") ? "$" : t
    }

    /// Relative, no "..", no absolute path, no backslash tricks.
    static func safe(_ p: String) -> Bool {
        !p.isEmpty && !p.contains("$") && !p.hasPrefix("/") && !p.contains("\\") && !p.split(separator: "/").contains("..")
    }
}
