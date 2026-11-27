import Foundation

/// wcp-import: installed packages live in <Application Support>/WCP/<name>/ (DLLs named as the bundle names them).
/// Nothing in a game's prefix is written; WineProcessBridge.m links from this folder when the game's own line says
/// `d3d11-package = <name>` (DXVK) or `d3d12-package = <name>` (vkd3d-proton). Undo = remove(name).
/// Off: env.MADEIRA_WCP_IMPORT = 0. DRAFT: Swift not compiled; the C part (SwiftWCP/wcp_untar.c) is host-tested.
enum WCPStore {
    struct Meta: Codable { var type: String; var versionName: String }

    enum Failure: Error { case off, notXZ, damaged, unsafe, tooBig, io, wrongArch(String, String), missing(String) }

    static var root: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("WCP", isDirectory: true)
    }

    /// The config key a package type is used through.
    static func key(forType t: String) -> String { t == "dxvk" ? "d3d11-package" : "d3d12-package" }

    /// Files the bundle's route needs (the names the bridge checks), as named inside the package.
    static func required(_ type: String) -> [String] {
        type == "dxvk" ? ["d3d11.dll", "d3d10core.dll", "dxgi.dll"] : ["d3d12.dll", "d3d12core.dll"]
    }

    /// Package name safe as a folder and as a config value (letters, digits, "-" and "." only).
    static func folderName(_ p: WCPProfile) -> String {
        var raw = "\(p.type)-\(p.versionName)".lowercased().map { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "." ? $0 : "_" }
        if raw.count > 100 { raw = Array(raw.prefix(100)) }
        return String(raw).replacingOccurrences(of: "..", with: "_")
    }

    /// Unpacks `file`, checks it, and keeps the 64-bit DLLs the route needs. Every one must be ARM64EC, as the bundle's are.
    /// Runs off the main thread. Returns the package name.
    static func importPackage(_ file: URL) throws -> String {
        guard WCPProfile.enabled else { throw Failure.off }
        let fm = FileManager.default
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        let work = fm.temporaryDirectory.appendingPathComponent("wcp-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: work) }
        let access = file.startAccessingSecurityScopedResource()
        defer { if access { file.stopAccessingSecurityScopedResource() } }
        switch wcp_untar_xz(file.path, work.path, 400, 512 << 20) {   // WCP_OK = 0 ...
        case 0: break
        case 1: throw Failure.notXZ
        case 3: throw Failure.unsafe
        case 4: throw Failure.tooBig
        case 5, 6: throw Failure.io
        default: throw Failure.damaged
        }
        let profile = try WCPProfile.parse(Data(contentsOf: work.appendingPathComponent("profile.json")))
        let name = folderName(profile)
        let tmp = root.appendingPathComponent(".new-" + UUID().uuidString, isDirectory: true)
        try fm.createDirectory(at: tmp, withIntermediateDirectories: true)
        do {
            let byName = Dictionary(profile.files.filter { $0.target.hasPrefix("${system32}/") }
                .map { (($0.target as NSString).lastPathComponent.lowercased(), $0) },
                uniquingKeysWith: { first, _ in first })
            for need in required(profile.type) {
                guard let e = byName[need] else { throw Failure.missing(need) }
                let src = work.appendingPathComponent(e.source)
                let values = try? src.resourceValues(forKeys: [.isSymbolicLinkKey, .isRegularFileKey])
                guard src.standardizedFileURL.path.hasPrefix(work.standardizedFileURL.path + "/"),
                      values?.isRegularFile == true, values?.isSymbolicLink != true else { throw Failure.unsafe }
                let kind = wcp_pe_kind(src.path)
                guard kind == 2 else { throw Failure.wrongArch(need, kindName(kind)) }   // WCP_PE_ARM64EC
                try fm.copyItem(at: src, to: tmp.appendingPathComponent(profile.type == "dxvk" ? "dxvk-" + need : need))
            }
            try JSONEncoder().encode(Meta(type: profile.type, versionName: profile.versionName)).write(to: tmp.appendingPathComponent("meta.json"))
            let dest = root.appendingPathComponent(name, isDirectory: true)
            try? fm.removeItem(at: dest)
            try fm.moveItem(at: tmp, to: dest)
        } catch { try? fm.removeItem(at: tmp); throw error }
        LogStore.shared.log("[wcp] imported \(name) (\(profile.files.count) files listed, \(required(profile.type).count) kept)", level: .info)
        return name
    }

    static func kindName(_ k: Int32) -> String {
        switch k { case 1: return "plain x64"; case 2: return "ARM64EC"; case 3: return "ARM64"; case 4: return "32-bit x86"; default: return "unknown" }
    }

    static func message(_ e: Error) -> String {
        switch e {
        case Failure.off: return "Package import is switched off (env.MADEIRA_WCP_IMPORT = 0)."
        case Failure.notXZ: return "This isn't a .wcp package (not an xz archive)."
        case Failure.damaged: return "The package is damaged or cut short."
        case Failure.unsafe: return "The package contains links or file names that aren't allowed."
        case Failure.tooBig: return "The package is too big or has too many files."
        case Failure.io: return "The package could not be written to the app's storage."
        case Failure.wrongArch(let f, let k): return "\(f) is \(k); Madeira needs ARM64EC DLLs. Use the package's ARM64EC build."
        case Failure.missing(let f): return "The package has no \(f)."
        default: return WCPProfile.message(e)
        }
    }

    struct Installed { var name: String; var meta: Meta }

    static func installed() -> [Installed] {
        let names = ((try? FileManager.default.contentsOfDirectory(atPath: root.path)) ?? []).filter { !$0.hasPrefix(".") }.sorted()
        return names.compactMap { n in
            guard let d = try? Data(contentsOf: root.appendingPathComponent(n).appendingPathComponent("meta.json")),
                  let m = try? JSONDecoder().decode(Meta.self, from: d) else { return nil }
            return Installed(name: n, meta: m)
        }
    }

    /// The undo: delete the folder. A game whose line still names it falls back to the bundle's DLLs (and the log says so).
    static func remove(_ name: String) { try? FileManager.default.removeItem(at: root.appendingPathComponent(name)) }

    /// `config` with the game's line for `key` set to `name` (nil: line removed). Other lines untouched.
    static func setLine(_ config: String, key: String, to name: String?) -> String {
        var lines = config.components(separatedBy: "\n").filter { !($0.trimmingCharacters(in: .whitespaces).hasPrefix(key + " ") || $0.trimmingCharacters(in: .whitespaces).hasPrefix(key + "=")) }
        while lines.last == "" { lines.removeLast() }
        if let name { lines.append("\(key) = \(name)") }
        return lines.joined(separator: "\n") + "\n"
    }
}
