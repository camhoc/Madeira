//
//  StorageManager.swift (storage-screen, Nov 26 2026): Settings > Storage > "What is using storage".
//
//  A tester asked for (a) an easier way to see what is consuming storage, (b) multi-delete of games and
//  files, (c) a way to have a removed game's files go with it. This file is (a) and (b), and the helpers
//  for (c) (the Remove dialog's switch is in Library.swift, same package).
//
//  The screen shows, from the top:
//   - Madeira's total, and free space on the device.
//   - Games (every store's installs, sorted by size) and Added programs (library entries without a store).
//   - Safe to clear: logs, caches, temporary files, crash reports, partial downloads, leftover install
//     folders, and shader / temporary caches inside the Windows drive.
//   - Everything on this device: every top-level folder of the app's Documents, Application Support,
//     Caches, tmp and Library, with the Windows drive broken into its own folders. This is the hidden
//     space (prefix, runtime files, caches) that "games" alone never explained.
//  Select picks several rows; a row's tap asks to delete that one. One confirm sheet lists what goes.
//  Saves are NEVER deleted unless the sheet's "Also delete saves and settings" is on (off every time).
//
//  Off switches (madeira.cfg): env.MADEIRA_STORAGE_SCREEN = 0 hides the page;
//  env.MADEIRA_STORAGE_DELETE = 0 makes it look-only (no Select, no delete);
//  env.MADEIRA_REMOVE_FILES_TOGGLE = 0 hides the Remove dialog's file switches (Library details).
//
//  Crash-report rules kept: every disk read and delete of folders runs off the main thread (a detached
//  task); sizes arrive as they are found; the delete run holds a continued-processing task
//  (MoveBackground.uninstall) and its state lives in this singleton, not in a view.
//
//  Games go through each store's own uninstall (Steam's guarded beginUninstall, Epic, GOG, EA, itch.io);
//  nothing here deletes a store game's folder by path.
//

import SwiftUI
import UIKit

enum StorageUsage {
    static var enabled: Bool { MadeiraConfig.flag("MADEIRA_STORAGE_SCREEN") }
    static var deleteEnabled: Bool { MadeiraConfig.flag("MADEIRA_STORAGE_DELETE") }
    static var removeFilesEnabled: Bool { MadeiraConfig.flag("MADEIRA_REMOVE_FILES_TOGGLE") }
    /// Rows open their folder in the Files app (shareddocuments://) when it is under Documents. 0: as before (info rows did nothing).
    static var filesLinkEnabled: Bool { MadeiraConfig.flag("MADEIRA_STORAGE_FILES_LINK") }
    /// Leftover install folders can be deleted only with env.MADEIRA_STORAGE_ORPHAN_DELETE = 1 (default off: shown, not deletable),
    /// because a game another launcher installed in a store's folder looks the same to Madeira.
    /// The two "Recently Deleted / recycle bin" rows can be emptied. 0: they only show in Everything on this device.
    static var trashRowsEnabled: Bool { MadeiraConfig.flag("MADEIRA_STORAGE_TRASH_ROWS") }
    static var orphanDeleteEnabled: Bool { MadeiraConfig.flag("MADEIRA_STORAGE_ORPHAN_DELETE", fallback: false) }
}

private let storageFilesKey = "madeira.storage.alsoFiles"

// MARK: - Rows

struct StorageRow: Identifiable, Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case steam(Int)
        case epic(String)
        case gog(String)
        case ea(String)
        case itch(Int)
        case program(UUID)
        /// Empty these folders (their files go; folders inside are emptied and stay).
        case clear([URL])
        /// Delete these folders themselves.
        case remove([URL])
        case info
    }
    let id: String
    var title: String
    var detail: String
    var bytes: Int64?
    var kind: Kind
    /// Folder names a game's saves are likely to be under (matched exactly, never loosely).
    var names: [String] = []
    var external = false
    /// The folder's path under Documents ("wine/drive_c/Games/Foo"), what the Files app shows it as; nil when the
    /// folder is not in Documents (Application Support, Caches, tmp, an external drive: Files cannot show those).
    var filesPath: String?

    var deletable: Bool { if case .info = kind { return false }; return true }
    var isGame: Bool {
        switch kind { case .steam, .epic, .gog, .ea, .itch, .program: return true; default: return false }
    }
    var isProgram: Bool { if case .program = kind { return true }; return false }
}

// MARK: - Disk work (never on the main thread)

enum StorageScan {
    /// Bytes on disk of a file or folder. Links are not followed (an external drive's link counts 0).
    static func size(of url: URL) -> Int64 {
        guard let values = try? url.resourceValues(forKeys: [.isSymbolicLinkKey, .isDirectoryKey, .totalFileAllocatedSizeKey]) else { return 0 }
        if values.isSymbolicLink == true { return 0 }
        if values.isDirectory != true { return Int64(values.totalFileAllocatedSize ?? 0) }
        guard let walker = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .isRegularFileKey], options: []) else { return 0 }
        var total: Int64 = 0
        var visited = 0
        for case let file as URL in walker {
            visited += 1
            if visited % 256 == 0, Task.isCancelled { break }
            if let v = try? file.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .isRegularFileKey]), v.isRegularFile == true {
                total += Int64(v.totalFileAllocatedSize ?? 0)
            }
        }
        return total
    }

    static func capacity() -> (free: Int64, total: Int64)? {
        let url = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        guard let v = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey]),
              let free = v.volumeAvailableCapacityForImportantUsage, let total = v.volumeTotalCapacity else { return nil }
        return (free, Int64(total))
    }

    /// `url`'s path under Documents ("wine/drive_c/Games"), or nil when it is not inside Documents.
    static func documentsPath(_ url: URL, documents: URL) -> String? {
        let u = url.resolvingSymlinksInPath().standardizedFileURL.path
        let d = documents.resolvingSymlinksInPath().standardizedFileURL.path
        guard u.hasPrefix(d + "/"), u.count > d.count + 1 else { return nil }
        let rel = String(u.dropFirst(d.count + 1))
        if rel.split(separator: "/").contains(where: { $0.hasPrefix(".") }) { return nil }   // hidden folders (.Trash) are not shown by Files
        return rel
    }

    static func children(of url: URL) -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
    }

    static func isLink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]))?.isSymbolicLink == true
    }

    /// Folder names (lower case) of shader and temporary caches inside the Windows drive's users.
    static let cacheFolderNames: Set<String> = ["shadercache", "d3dscache", "dxcache", "glcache", "gpucache", "code cache"]

    /// Shader and temporary cache folders in drive_c/users (the Steam client's own folder is never entered:
    /// its sign-in state lives there), plus drive_c/windows/temp.
    static func prefixCaches(drive: URL) -> [URL] {
        var found: [URL] = []
        let users = drive.appendingPathComponent("users", isDirectory: true)
        if let walker = FileManager.default.enumerator(at: users, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey], options: [.skipsPackageDescendants]) {
            var visited = 0
            for case let url as URL in walker {
                visited += 1
                if visited > 40_000 || Task.isCancelled { break }
                if walker.level > 7 { walker.skipDescendants(); continue }
                guard let v = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey]),
                      v.isDirectory == true, v.isSymbolicLink != true else { continue }
                let name = url.lastPathComponent.lowercased()
                if name == "steam" { walker.skipDescendants(); continue }
                if cacheFolderNames.contains(name) { found.append(url); walker.skipDescendants() }
            }
        }
        // Windows' own temp folders, by exact place (a game's own "Temp" folder elsewhere is never touched).
        var fixed = [drive.appendingPathComponent("windows/temp", isDirectory: true)]
        for user in (try? FileManager.default.contentsOfDirectory(atPath: users.path)) ?? [] {
            let home = users.appendingPathComponent(user, isDirectory: true)
            fixed.append(home.appendingPathComponent("Temp", isDirectory: true))
            fixed.append(home.appendingPathComponent("AppData/Local/Temp", isDirectory: true))
            fixed.append(home.appendingPathComponent("AppData/Local/CrashDumps", isDirectory: true))
        }
        for url in fixed where FileManager.default.fileExists(atPath: url.path) && !isLink(url) { found.append(url) }
        return found
    }

    /// True when `url` is strictly inside `root` (both standardized, links resolved).
    static func inside(_ url: URL, _ root: URL) -> Bool {
        let u = url.resolvingSymlinksInPath().standardizedFileURL.path
        let r = root.resolvingSymlinksInPath().standardizedFileURL.path
        return u.count > r.count + 1 && u.hasPrefix(r + "/")
    }

    /// The only places this screen ever deletes in: the app's own container and the Windows drive.
    static func allowed(_ url: URL, drive: URL) -> Bool {
        if isLink(url) { return false }
        return inside(url, URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)) || inside(url, drive)
    }

    /// Empties `dir`: its files go, and each folder inside it is emptied but stays (a cache folder the app
    /// made once at start, such as Caches/madeira-covers, must still be there afterwards).
    static func removeChildren(of dir: URL, drive: URL) -> Int {
        let fm = FileManager.default
        var count = 0
        if isLink(dir) { return 0 }   // never empty a folder that is a link (it could point at something else)
        for child in children(of: dir) where allowed(child, drive: drive) {
            let isFolder = (try? child.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
            if isFolder {
                for inner in children(of: child) where allowed(inner, drive: drive) {
                    if (try? fm.removeItem(at: inner)) != nil { count += 1 }
                }
            } else if (try? fm.removeItem(at: child)) != nil { count += 1 }
        }
        return count
    }

    static func removeFolder(_ url: URL, drive: URL) -> Bool {
        guard allowed(url, drive: drive) else { return false }
        return (try? FileManager.default.removeItem(at: url)) != nil
    }
}

/// Where a game keeps saves and settings in the Windows drive, found by EXACT folder name only
/// (the game's title, its install folder's name, its program's name). A game whose saves sit under a
/// publisher's name is not found, and nothing is guessed: the sheet says how many folders were found.
enum SaveFinder {
    static let roots = ["Documents/My Games", "Documents", "Saved Games", "AppData/Roaming", "AppData/LocalLow", "AppData/Local"]
    static let generic: Set<String> = ["my games", "microsoft", "packages", "steam", "temp", "nvidia", "madeira", "common", "windows",
                                        "games", "data", "saves", "save", "config", "cache", "caches", "logs", "unity", "local",
                                        "locallow", "roaming", "desktop", "downloads", "music", "pictures", "videos", "program files", "launcher", "bin", "bin64", "binaries", "release", "debug", "game",
                                        "documents", "programs", "saved games", "crashdumps", "win64", "win32", "x64", "x86", "app", "client", "server", "engine", "content", "shipping", "main", "play", "start"]

    static func folders(names: [String], drive: URL) -> [URL] {
        let wanted = Set(names.map { $0.lowercased() }.filter { $0.count >= 3 && !generic.contains($0) })
        guard !wanted.isEmpty else { return [] }
        let fm = FileManager.default
        let users = drive.appendingPathComponent("users", isDirectory: true)
        var found: [URL] = []
        for user in (try? fm.contentsOfDirectory(atPath: users.path)) ?? [] {
            for root in roots {
                let base = users.appendingPathComponent(user, isDirectory: true).appendingPathComponent(root, isDirectory: true)
                for child in (try? fm.contentsOfDirectory(atPath: base.path)) ?? [] where wanted.contains(child.lowercased()) {
                    let url = base.appendingPathComponent(child, isDirectory: true)
                    if let v = try? url.resourceValues(forKeys: [.isSymbolicLinkKey, .isDirectoryKey]),
                       v.isSymbolicLink != true, v.isDirectory == true { found.append(url) }
                }
            }
        }
        return found
    }

    static func bytes(of folders: [URL]) -> Int64 { folders.reduce(0) { $0 + StorageScan.size(of: $1) } }
}

/// What an added program's folder is, if it is safe to delete as "the game's files".
enum ProgramFolder {
    struct Owner: Sendable { let owner: String; let path: String }   // path: drive-relative, lower case

    /// The folder holding `relativePath`'s program, or nil when it must not be deleted: too shallow,
    /// a Windows or shared folder, the Steam client, or any other library entry / store install that is
    /// the same folder or lies inside or around it.
    static func url(relativePath: String, owner: String, others: [Owner], drive: URL) -> URL? {
        let parts = relativePath.replacingOccurrences(of: "\\", with: "/").split(separator: "/").map(String.init)
        guard parts.count >= 3 || (parts.count == 2 && parts[0].lowercased() != "external") else { return nil }   // folder + program (External needs a drive folder too)
        let folderParts = Array(parts.dropLast())
        guard let first = folderParts.first?.lowercased(),
              !["windows", "users", "programdata", "external"].contains(first) || (first == "external" && folderParts.count >= 3) else { return nil }
        let folder = folderParts.joined(separator: "/").lowercased()
        if GameOwnLogs.sharedFolders.contains(folder) { return nil }
        if ["program files/common files", "program files (x86)/common files", "program files/windows nt", "program files/windowsapps",
            "program files/windows nt/accessories", "program files/internet explorer"].contains(folder) { return nil }
        if folder == "program files (x86)/steam" || folder == "program files/steam" { return nil }
        // Store-owned places: a Steam library, and the folders the Epic, GOG, EA and itch.io installs live in.
        if folderParts.contains(where: { $0.lowercased() == "steamapps" }) { return nil }
        let storeRoots = ["program files/epic games/", "gog games/", "program files/ea games/", "itch/", "program files (x86)/steam/"]
        if storeRoots.contains(where: { (folder + "/").hasPrefix($0) }) { return nil }
        for other in others where other.owner != owner {
            let p = other.path
            if p == folder || p.hasPrefix(folder + "/") || folder.hasPrefix(p + "/") { return nil }
        }
        var target = drive
        for part in folderParts { target.appendPathComponent(part, isDirectory: true) }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: target.path, isDirectory: &isDirectory), isDirectory.boolValue,
              !StorageScan.isLink(target), StorageScan.inside(target, drive) else { return nil }
        return target
    }
}

// MARK: - Model

@MainActor final class StorageModel: ObservableObject {
    static let shared = StorageModel()

    struct Capacity: Equatable { var free: Int64; var total: Int64 }

    @Published private(set) var games: [StorageRow] = []
    @Published private(set) var programs: [StorageRow] = []
    @Published private(set) var cleanable: [StorageRow] = []
    @Published private(set) var everything: [StorageRow] = []
    @Published private(set) var deviceTotal: Int64 = 0
    @Published private(set) var externalTotal: Int64 = 0
    @Published private(set) var capacity: Capacity?
    @Published private(set) var scanning = false
    @Published private(set) var scanned = false
    @Published private(set) var selecting = false
    @Published private(set) var selected = Set<String>()
    /// What the confirm sheet is about to delete.
    @Published var pending: [StorageRow] = []
    /// The sheet's switches. "Also delete the program's folder" is remembered; saves are off every time.
    @Published var alsoFiles: Bool = UserDefaults.standard.bool(forKey: storageFilesKey) {
        didSet { UserDefaults.standard.set(alsoFiles, forKey: storageFilesKey) }
    }
    @Published var alsoSaves = false
    @Published private(set) var running = false
    @Published private(set) var progressText = ""
    /// The last run's lines ("3 removed", then one per skipped item).
    @Published var report: [String] = []

    private var scanTask: Task<Void, Never>?
    private var scanGeneration = 0
    private var runTask: Task<Void, Never>?

    private enum Outcome { case removed, skipped(String) }

    // MARK: Select

    func beginSelecting() { guard StorageUsage.deleteEnabled, !running else { return }; selecting = true; selected = [] }
    func endSelecting() { selecting = false; selected = [] }
    func toggle(_ row: StorageRow) {
        guard selecting, row.deletable, !running else { return }
        if selected.contains(row.id) { selected.remove(row.id) } else { selected.insert(row.id) }
    }
    var selectedRows: [StorageRow] { (games + programs + cleanable).filter { selected.contains($0.id) } }
    var selectedBytesText: String {
        let rows = selectedRows
        let known = rows.compactMap(\.bytes).reduce(0, +)
        let text = ByteCountFormatter.string(fromByteCount: known, countStyle: .file)
        return rows.contains { $0.bytes == nil } ? String(format: L("At least %@"), text) : text
    }

    /// True when the confirm sheet may open.
    @discardableResult func ask(_ rows: [StorageRow]) -> Bool {
        guard StorageUsage.deleteEnabled, !running, !rows.isEmpty else { return false }
        alsoSaves = false
        pending = rows
        return true
    }

    // MARK: Scan

    /// Rows from what is in memory now, then sizes and the folders from a detached task.
    func refresh() {
        guard !scanning else { return }
        let (gameRows, programRows) = memoryRows()
        games = sorted(gameRows); programs = sorted(programRows)
        scanning = true
        scanGeneration += 1
        let generation = scanGeneration
        let input = scanInput(games: gameRows, programs: programRows)
        scanTask = Task { @MainActor in
            let result = await Task.detached(priority: .utility) { StorageModel.scan(input) }.value
            guard generation == self.scanGeneration else { return }
            self.apply(result)
        }
    }

    private func sorted(_ rows: [StorageRow]) -> [StorageRow] {
        rows.sorted {
            switch ($0.bytes, $1.bytes) {
            case let (a?, b?): return a != b ? a > b : $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            case (nil, _?): return false
            case (_?, nil): return true
            default: return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        }
    }

    private static func last(_ folder: String) -> String { (folder as NSString).lastPathComponent }

    /// Files path of a drive-relative folder, or nil for one on an external drive (a link Files does not follow).
    private static func driveFiles(_ relative: String) -> String? {
        let clean = relative.replacingOccurrences(of: "\\", with: "/")
        if clean.lowercased().hasPrefix("external/") || clean.hasPrefix("/") { return nil }
        return "wine/drive_c/" + clean
    }

    private func memoryRows() -> ([StorageRow], [StorageRow]) {
        let entries = LibraryModel.shared.entries
        var games: [StorageRow] = []
        for g in SteamGamesModel.shared.games where g.installed {
            let managed = SteamInstallPaths.isManaged(library: g.library)
            let known = entries.first(where: { $0.steamAppID == g.id })?.folderBytes
            games.append(StorageRow(id: "steam-\(g.id)", title: g.name,
                                    detail: managed ? L("Steam") : L("Steam. Installed by Steam, remove it in Steam."),
                                    bytes: (known ?? 0) > 0 ? known : nil, kind: managed ? .steam(g.id) : .info,
                                    names: [g.name, g.installDir], filesPath: Self.driveFiles(g.library + "/common/" + g.installDir)))
        }
        for (key, g) in EpicLibrary.shared.installed {
            games.append(StorageRow(id: "epic-\(key)", title: g.title, detail: L("Epic Games"), bytes: g.installBytes > 0 ? g.installBytes : nil,
                                    kind: .epic(key), names: [g.title, Self.last(g.folder)], filesPath: Self.driveFiles(g.folder)))
        }
        for (key, g) in GOGLibrary.shared.installed {
            games.append(StorageRow(id: "gog-\(key)", title: g.title, detail: "GOG", bytes: g.installBytes > 0 ? g.installBytes : nil,
                                    kind: .gog(key), names: [g.title, Self.last(g.folder)], filesPath: Self.driveFiles(g.folder)))
        }
        for (key, g) in EALibrary.shared.installed {
            games.append(StorageRow(id: "ea-\(key)", title: g.title, detail: L("EA app"), bytes: g.installBytes > 0 ? g.installBytes : nil,
                                    kind: .ea(key), names: [g.title, Self.last(g.folder)], filesPath: Self.driveFiles(g.folder)))
        }
        for (key, g) in ItchLibrary.shared.installed {
            games.append(StorageRow(id: "itch-\(key)", title: g.title, detail: "itch.io", bytes: g.installBytes > 0 ? g.installBytes : nil,
                                    kind: .itch(key), names: [g.title, Self.last(g.folder)], filesPath: Self.driveFiles(g.folder)))
        }
        var programs: [StorageRow] = []
        for e in entries where e.desktop != true && e.steamAppID == nil && e.gogProductID == nil && e.itchGameID == nil
            && e.epicAppName == nil && e.eaOfferID == nil {
            let exe = ((e.relativePath as NSString).lastPathComponent as NSString).deletingPathExtension
            let folder = (e.relativePath as NSString).deletingLastPathComponent
            programs.append(StorageRow(id: "program-\(e.id.uuidString)", title: e.title,
                                       detail: folder.isEmpty ? L("Added program") : folder,
                                       bytes: (e.folderBytes ?? 0) > 0 ? e.folderBytes : nil, kind: .program(e.id),
                                       names: [e.title, Self.last(folder), exe], filesPath: folder.isEmpty ? nil : Self.driveFiles(folder)))
        }
        return (games, programs)
    }

    /// Every library program path and store install folder (drive-relative, lower case), with its owner.
    private func ownerPaths() -> [ProgramFolder.Owner] {
        var out: [ProgramFolder.Owner] = []
        for e in LibraryModel.shared.entries {
            out.append(.init(owner: "program-\(e.id.uuidString)", path: e.relativePath.replacingOccurrences(of: "\\", with: "/").lowercased()))
        }
        for g in EpicLibrary.shared.installed.values { out.append(.init(owner: "store", path: g.folder.lowercased())) }
        for g in GOGLibrary.shared.installed.values { out.append(.init(owner: "store", path: g.folder.lowercased())) }
        for g in EALibrary.shared.installed.values { out.append(.init(owner: "store", path: g.folder.lowercased())) }
        for g in ItchLibrary.shared.installed.values { out.append(.init(owner: "store", path: g.folder.lowercased())) }
        return out
    }

    private struct SizeJob: Sendable {
        enum Work: Sendable { case steam(Int, String), program(String) }
        let id: String
        let work: Work
    }
    private struct ScanInput: Sendable {
        var jobs: [SizeJob]
        var owners: [ProgramFolder.Owner]
        var orphanRoots: [(title: String, root: String)]
        var orphanDelete = StorageUsage.orphanDeleteEnabled
    }
    private struct ScanOutput: Sendable {
        var sizes: [String: Int64] = [:]
        var everything: [StorageRow] = []
        var cleanable: [StorageRow] = []
        var deviceTotal: Int64 = 0
        var externalTotal: Int64 = 0
        var capacity: Capacity?
        var driveExternal = false
    }

    private func scanInput(games: [StorageRow], programs: [StorageRow]) -> ScanInput {
        var jobs: [SizeJob] = []
        for row in games where row.bytes == nil {
            if case .steam(let appID) = row.kind, let g = SteamGamesModel.shared.games.first(where: { $0.id == appID }) {
                jobs.append(SizeJob(id: row.id, work: .steam(appID, g.library)))
            }
        }
        let entries = LibraryModel.shared.entries
        for row in programs where row.bytes == nil {
            if case .program(let id) = row.kind, let e = entries.first(where: { $0.id == id }) {
                jobs.append(SizeJob(id: row.id, work: .program(e.relativePath)))
            }
        }
        return ScanInput(jobs: jobs, owners: ownerPaths(),
                         orphanRoots: [(L("Epic Games"), EpicLibrary.installRoot), ("GOG", GOGLibrary.installRoot),
                                       (L("EA app"), EALibrary.installRoot), ("itch.io", ItchLibrary.installRoot)])
    }

    private nonisolated static func scan(_ input: ScanInput) -> ScanOutput {
        let fm = FileManager.default
        let drive = LibraryModel.drive
        let docs = LibraryModel.documents
        let home = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first
        let tmp = fm.temporaryDirectory
        var out = ScanOutput()
        if let c = StorageScan.capacity() { out.capacity = Capacity(free: c.free, total: c.total) }

        // 1. Sizes the rows did not have (game and program folders).
        for job in input.jobs {
            if Task.isCancelled { return out }
            switch job.work {
            case .steam(let appID, let library):
                if let s = SteamInstallFiles.sizeOnDisk(appID: appID, steamApps: drive.appendingPathComponent(library, isDirectory: true)) { out.sizes[job.id] = s }
            case .program(let relative):
                if let folder = ProgramFolder.url(relativePath: relative, owner: job.id, others: input.owners, drive: drive) { out.sizes[job.id] = StorageScan.size(of: folder) }
            }
        }

        // 2. Everything on this device: top-level folders, the Windows drive split into its own folders.
        struct Item { let title: String; let url: URL; let external: Bool }
        var items: [Item] = []
        var seen = Set<String>()
        func add(_ title: String, _ url: URL, external: Bool = false) {
            let key = url.standardizedFileURL.path
            if seen.insert(key).inserted { items.append(Item(title: title, url: url, external: external)) }
        }
        let docsResolved = docs.resolvingSymlinksInPath().path
        let driveExternal = !drive.path.hasPrefix(docsResolved + "/")
        out.driveExternal = driveExternal
        let friendlyDocs: [String: String] = ["logs": L("Logs"), "madeira-art": L("Cover art"),
                                              ".trash": L("Recently Deleted (files deleted from Madeira's folder in Files)")]
        for c in StorageScan.children(of: docs) {
            let name = c.lastPathComponent
            if name == "wine" {
                for w in StorageScan.children(of: c) where w.lastPathComponent != "drive_c" {
                    add(w.lastPathComponent == ".Trash" ? L("Windows recycle bin (files deleted inside a game or Windows program)") : L("Wine prefix: ") + w.lastPathComponent, w)
                }
                continue
            }
            add(friendlyDocs[name.lowercased()] ?? (L("Documents: ") + name), c)
        }
        let friendlyDrive: [String: String] = [
            "users": L("Windows drive: users (saves, app data, shader caches)"),
            "windows": L("Windows drive: Windows system files"),
            "external": L("Windows drive: External (drives, counted on the drives)")]
        for c in StorageScan.children(of: drive) {
            let name = c.lastPathComponent
            add(friendlyDrive[name.lowercased()] ?? (L("Windows drive: ") + name), c, external: driveExternal)
        }
        let friendlySupport: [String: String] = ["crashreports": L("Crash reports"), "mods": L("Mods"),
                                                  "itch-downloads": L("Partial itch.io downloads"), "madeiradock": L("Madeira Dock files")]
        if let support {
            for c in StorageScan.children(of: support) { add(friendlySupport[c.lastPathComponent.lowercased()] ?? (L("App data: ") + c.lastPathComponent), c) }
        }
        if let caches { for c in StorageScan.children(of: caches) { add(L("Caches: ") + c.lastPathComponent, c) } }
        let library = home.appendingPathComponent("Library", isDirectory: true)
        for c in StorageScan.children(of: library) where !["application support", "caches"].contains(c.lastPathComponent.lowercased()) {
            add(L("Library: ") + c.lastPathComponent, c)
        }
        var tmpBytes: Int64 = 0
        for c in StorageScan.children(of: tmp) { if Task.isCancelled { return out }; tmpBytes += StorageScan.size(of: c) }

        var measured: [(Item, Int64)] = []
        for item in items {
            if Task.isCancelled { return out }
            measured.append((item, item.external && StorageScan.isLink(item.url) ? 0 : StorageScan.size(of: item.url)))
        }
        if tmpBytes > 0 { measured.append((Item(title: L("Temporary files"), url: tmp, external: false), tmpBytes)) }
        measured.sort { $0.1 > $1.1 }
        var small: Int64 = 0, smallCount = 0
        for (item, bytes) in measured {
            if item.external { out.externalTotal += bytes } else { out.deviceTotal += bytes }
            if bytes < 1_000_000 { small += item.external ? 0 : bytes; smallCount += item.external ? 0 : 1; continue }
            out.everything.append(StorageRow(id: "all-" + item.url.path, title: item.title, detail: item.external ? L("On an external drive") : "",
                                             bytes: bytes, kind: .info, external: item.external,
                                             filesPath: item.external ? nil : StorageScan.documentsPath(item.url, documents: docs)))
        }
        if smallCount > 0 {
            out.everything.append(StorageRow(id: "all-small", title: String(format: L("%d smaller items"), smallCount), detail: "", bytes: small, kind: .info))
        }

        // 3. Safe to clear.
        func clearRow(_ id: String, _ title: String, _ detail: String, _ dir: URL?) {
            guard let dir, fm.fileExists(atPath: dir.path) else { return }
            let bytes = StorageScan.size(of: dir)
            if bytes > 0 {
                out.cleanable.append(StorageRow(id: id, title: title, detail: detail, bytes: bytes, kind: .clear([dir]),
                                                filesPath: StorageScan.documentsPath(dir, documents: docs)))
            }
        }
        // Hidden folders: iOS Files' "Recently Deleted" for this app (Documents/.Trash) and Wine's recycle bin
        // (wine/.Trash). Both hold things already deleted, and neither shows in Files > On My iPhone > Madeira.
        if StorageUsage.trashRowsEnabled {
            clearRow("clear-files-trash", L("Recently Deleted (from Files)"),
                     L("Things you deleted from Madeira's folder in the Files app go here, and stay until emptied. In Files they are under Browse > Recently Deleted. Emptying is permanent."),
                     docs.appendingPathComponent(".Trash", isDirectory: true))
            clearRow("clear-wine-trash", L("Windows recycle bin"),
                     L("Files deleted from inside Windows programs and games. Emptying is permanent."),
                     docs.appendingPathComponent("wine/.Trash", isDirectory: true))
        }
        clearRow("clear-logs", L("Logs"), L("Past game logs."), docs.appendingPathComponent("logs", isDirectory: true))
        clearRow("clear-crash", L("Crash reports"), L("Reports from earlier crashes."), support?.appendingPathComponent("CrashReports", isDirectory: true))
        clearRow("clear-caches", L("Caches"), L("Cover pictures and system caches. They are made again."), caches)
        clearRow("clear-tmp", L("Temporary files"), L("Files the app left in its temporary folder."), tmp)
        clearRow("clear-itch-partial", L("Partial itch.io downloads"), L("Downloads that did not finish. They cannot resume after this."), support?.appendingPathComponent("itch-downloads", isDirectory: true))
        clearRow("clear-steam-partial", L("Partial Steam downloads"), L("Downloads that did not finish. They cannot resume after this."),
                 SteamInstallPaths.steamApps(drive: drive).appendingPathComponent("downloading", isDirectory: true))
        let prefixCaches = StorageScan.prefixCaches(drive: drive)
        if !prefixCaches.isEmpty {
            let bytes = prefixCaches.reduce(Int64(0)) { $0 + StorageScan.size(of: $1) }
            if bytes > 0 {
                out.cleanable.append(StorageRow(id: "clear-prefix-caches", title: L("Shader and temporary caches in the Windows drive"),
                                                detail: L("Games make them again. The first start after this can be slower."),
                                                bytes: bytes, kind: .clear(prefixCaches)))
            }
        }
        // Install folders no store record and no library entry points at (partial installs, old builds).
        for (title, root) in input.orphanRoots {
            let base = drive.appendingPathComponent(root, isDirectory: true)
            var urls: [URL] = [], names: [String] = []
            for c in StorageScan.children(of: base) {
                var isDirectory: ObjCBool = false
                guard fm.fileExists(atPath: c.path, isDirectory: &isDirectory), isDirectory.boolValue, !StorageScan.isLink(c) else { continue }
                let rel = (root + "/" + c.lastPathComponent).lowercased()
                let used = input.owners.contains { $0.path == rel || $0.path.hasPrefix(rel + "/") || rel.hasPrefix($0.path + "/") }
                if !used { urls.append(c); names.append(c.lastPathComponent) }
            }
            if urls.isEmpty { continue }
            let bytes = urls.reduce(Int64(0)) { $0 + StorageScan.size(of: $1) }
            var orphanDetail = L("Not known to Madeira: ") + names.prefix(3).joined(separator: ", ")
            if names.count > 3 { orphanDetail += "…" }
            orphanDetail += L(". Games installed by the store's own launcher would show here too.")
            if !input.orphanDelete { orphanDetail += L(" Shown only: deleting these is off.") }
            out.cleanable.append(StorageRow(id: "orphan-" + root, title: String(format: L("Leftover %@ install folders"), title),
                                            detail: orphanDetail,
                                            bytes: bytes, kind: input.orphanDelete ? .remove(urls) : .info))
        }
        out.cleanable.sort { ($0.bytes ?? 0) > ($1.bytes ?? 0) }
        return out
    }

    private func apply(_ result: ScanOutput) {
        scanning = false
        scanned = true
        func fill(_ rows: [StorageRow]) -> [StorageRow] {
            sorted(rows.map { row in var row = row; if row.bytes == nil, let s = result.sizes[row.id] { row.bytes = s }; return row })
        }
        games = fill(games)
        programs = fill(programs)
        if result.driveExternal {   // the Windows drive is not in Documents: its folders have no Files path
            games = games.map { var r = $0; r.filesPath = nil; return r }
            programs = programs.map { var r = $0; r.filesPath = nil; return r }
        }
        cleanable = result.cleanable
        everything = result.everything
        deviceTotal = result.deviceTotal
        externalTotal = result.externalTotal
        capacity = result.capacity
        selected = selected.filter { id in (games + programs + cleanable).contains { $0.id == id } }
        LogStore.shared.log("[storage] scan: device=\(result.deviceTotal) external=\(result.externalTotal) games=\(games.count) programs=\(programs.count) clearable=\(cleanable.count)")
    }

    // MARK: Delete

    func cancel() { runTask?.cancel() }

    /// Deletes `pending` one row at a time.
    func deleteNow() {
        guard StorageUsage.deleteEnabled, !running, !pending.isEmpty else { return }
        let rows = pending
        let files = alsoFiles, saves = alsoSaves
        pending = []
        running = true; report = []; selecting = false; selected = []
        let background = MoveBackground.uninstall
        background.batchStarted(L("Freeing storage"), total: rows.count) { [weak self] in self?.cancel() }
        LogStore.shared.log("[storage] delete start rows=\(rows.count) files=\(files) saves=\(saves)")
        runTask = Task { @MainActor in
            var removed = 0
            var notes: [String] = []
            for (index, row) in rows.enumerated() {
                if Task.isCancelled { notes.append(String(format: L("%d not started"), rows.count - index)); break }
                progressText = String(format: L("Removing %d of %d: %@"), index + 1, rows.count, row.title)
                background.batchStep(done: index, title: String(format: L("Removing %d of %d"), index + 1, rows.count))
                switch await removeOne(row, files: files, saves: saves) {
                case .removed:
                    removed += 1
                    LogStore.shared.log("[storage] \(index + 1)/\(rows.count) \(row.id) removed")
                case .skipped(let why):
                    notes.append("\(row.title): \(why)")
                    LogStore.shared.log("[storage] \(index + 1)/\(rows.count) \(row.id) skipped: \(why)")
                }
            }
            report = [String(format: L("%d removed"), removed)] + notes
            LogStore.shared.log("[storage] delete end removed=\(removed) notes=\(notes.count)")
            background.batchEnded()
            running = false; progressText = ""; runTask = nil
            scanTask?.cancel(); scanGeneration += 1; scanning = false   // a scan that began before the deletes is stale
            refresh()
        }
    }

    /// (also used by the Remove dialog on Library details) Deletes an added program's folder (`files`) and/or its
    /// saves (`saves`, exact-name folders only) BEFORE its library entry goes. nil: done; else why not (nothing
    /// was removed from the library). A folder that is shared or protected (ProgramFolder) is left alone.
    func removeProgramFiles(_ entry: LibraryEntry, files: Bool, saves: Bool) async -> String? {
        if let busy = busyReason() { return busy }
        let drive = await Task.detached(priority: .utility) { LibraryModel.drive }.value
        if files {
            let owners = ownerPaths(), relative = entry.relativePath, owner = "program-\(entry.id.uuidString)"
            let folder = await Task.detached(priority: .utility) {
                ProgramFolder.url(relativePath: relative, owner: owner, others: owners, drive: drive)
            }.value
            if let folder {
                let gone = await Task.detached(priority: .utility) { StorageScan.removeFolder(folder, drive: drive) }.value
                if !gone { return L("its folder could not be deleted; it stays in the library") }
                LogStore.shared.log("[storage] program folder removed for \(entry.title)")
            } else {
                LogStore.shared.log("[storage] program folder for \(entry.title) is shared or protected; only the library entry is removed")
            }
        }
        if saves {
            let exe = ((entry.relativePath as NSString).lastPathComponent as NSString).deletingPathExtension
            let names = [entry.title, Self.last((entry.relativePath as NSString).deletingLastPathComponent), exe]
            let count = await Task.detached(priority: .utility) { () -> Int in
                SaveFinder.folders(names: names, drive: drive).filter { StorageScan.removeFolder($0, drive: drive) }.count
            }.value
            LogStore.shared.log("[storage] saves removed folders=\(count) for \(entry.title)")
        }
        return nil
    }

    private var anyDownload: Bool {
        !SteamOwnedLibrary.shared.downloads.isEmpty || !EpicLibrary.shared.downloads.isEmpty || !GOGLibrary.shared.downloads.isEmpty
            || !EALibrary.shared.downloads.isEmpty || !ItchLibrary.shared.downloads.isEmpty
    }

    /// Why nothing may be deleted right now, or nil.
    private func busyReason() -> String? {
        if wine_process_is_running() != 0 || wineserver_is_running() != 0 || LibraryModel.shared.current != nil {
            return L("A game is running or starting. Close it, then try again.")
        }
        if GameMover.shared.moving != nil { return L("A game is being moved. Try again when it finishes.") }
        if BatchUninstall.shared.running { return L("Games are being removed from the Steam page. Try again when that finishes.") }
        return nil
    }

    private func removeOne(_ row: StorageRow, files: Bool, saves: Bool) async -> Outcome {
        if let busy = busyReason() { return .skipped(busy) }
        let drive = await Task.detached(priority: .utility) { LibraryModel.drive }.value
        let result: Outcome
        switch row.kind {
        case .steam(let appID):
            let steam = SteamOwnedLibrary.shared
            guard let game = SteamGamesModel.shared.games.first(where: { $0.id == appID }) else { return .skipped(L("it is no longer installed")) }
            if steam.downloads[appID] != nil { return .skipped(L("Still downloading. Try again when it finishes.")) }
            var waited = 0
            while steam.storageBusy(appID), waited < 150, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 200_000_000)
                waited += 1
            }
            if Task.isCancelled { return .skipped(L("stopped")) }
            guard let removal = steam.beginUninstall(game, report: false) else {
                return .skipped(steam.lastUninstallError ?? L("it could not be removed"))
            }
            result = await removal.value ? .removed : .skipped(steam.lastUninstallError ?? L("it could not be removed"))
        case .epic(let key):
            if EpicLibrary.shared.downloads[key] != nil { return .skipped(L("Still downloading. Try again when it finishes.")) }
            EpicLibrary.shared.uninstall(key)
            result = EpicLibrary.shared.installed[key] == nil ? .removed : .skipped(L("the store is busy (a game ran or a cloud sync is running)"))
        case .gog(let key):
            if GOGLibrary.shared.downloads[key] != nil { return .skipped(L("Still downloading. Try again when it finishes.")) }
            GOGLibrary.shared.uninstall(key)
            result = GOGLibrary.shared.installed[key] == nil ? .removed : .skipped(L("the store is busy"))
        case .ea(let key):
            if EALibrary.shared.downloads[key] != nil { return .skipped(L("Still downloading. Try again when it finishes.")) }
            EALibrary.shared.uninstall(key)
            result = EALibrary.shared.installed[key] == nil ? .removed : .skipped(L("it could not be removed"))
        case .itch(let key):
            if ItchLibrary.shared.downloads[key] != nil { return .skipped(L("Still downloading. Try again when it finishes.")) }
            ItchLibrary.shared.uninstall(key)
            result = ItchLibrary.shared.installed[key] == nil ? .removed : .skipped(L("the store is busy"))
        case .program(let id):
            guard let entry = LibraryModel.shared.entries.first(where: { $0.id == id }) else { return .skipped(L("it is no longer in the library")) }
            if let why = await removeProgramFiles(entry, files: files, saves: false) { return .skipped(why) }
            LibraryModel.shared.remove(entry.id)
            result = .removed
        case .clear(let urls):
            if anyDownload { return .skipped(L("A download is running. Try again when it finishes.")) }
            let count = await Task.detached(priority: .utility) { urls.reduce(0) { $0 + StorageScan.removeChildren(of: $1, drive: drive) } }.value
            LogStore.shared.log("[storage] cleared \(count) items in \(urls.count) folders")
            result = .removed
        case .remove(let urls):
            if anyDownload { return .skipped(L("A download is running. Try again when it finishes.")) }
            // The list was made at scan time: a folder a store record or library entry points at since is kept.
            let owners = ownerPaths()
            let count = await Task.detached(priority: .utility) { () -> Int in
                let driveRoot = drive.resolvingSymlinksInPath().standardizedFileURL.path + "/"
                return urls.filter { url in
                    let full = url.resolvingSymlinksInPath().standardizedFileURL.path
                    guard full.hasPrefix(driveRoot) else { return false }
                    let rel = String(full.dropFirst(driveRoot.count)).lowercased()
                    if owners.contains(where: { $0.path == rel || $0.path.hasPrefix(rel + "/") || rel.hasPrefix($0.path + "/") }) { return false }
                    return StorageScan.removeFolder(url, drive: drive)
                }.count
            }.value
            LogStore.shared.log("[storage] removed \(count) of \(urls.count) folders")
            result = count == urls.count ? .removed : .skipped(String(format: L("%d of %d folders could not be deleted"), urls.count - count, urls.count))
        case .info:
            return .skipped(L("this can't be deleted here"))
        }
        // Saves and settings: only with the sheet's switch, only exact-name folders, only after the game itself went.
        if saves, row.isGame, case .removed = result {
            let names = row.names
            let removedCount = await Task.detached(priority: .utility) { () -> Int in
                SaveFinder.folders(names: names, drive: drive).filter { StorageScan.removeFolder($0, drive: drive) }.count
            }.value
            LogStore.shared.log("[storage] saves removed folders=\(removedCount) for \(row.title)")
        }
        return result
    }
}

// MARK: - Settings section

struct StorageSection: View {
    let open: (SettingsSheet) -> Void
    @ObservedObject private var model = StorageModel.shared

    var body: some View {
        Group {
            summary
            if model.selecting && !model.selected.isEmpty { deleteBar }
            if !model.report.isEmpty { reportSection }
            if !model.games.isEmpty {
                Section {
                    ForEach(model.games) { rowView($0) }
                } header: { Text("Games") } footer: {
                    Text("A game's size is part of the Windows drive listed under Everything on this device. Games are removed through their store.")
                }
            }
            if !model.programs.isEmpty {
                Section {
                    ForEach(model.programs) { rowView($0) }
                } header: { Text("Added programs") } footer: {
                    Text("Removing one takes it out of the library. Its folder goes too only if you turn that on in the next step.")
                }
            }
            if !model.cleanable.isEmpty {
                Section {
                    ForEach(model.cleanable) { rowView($0) }
                } header: { Text("Safe to clear") } footer: {
                    Text("Nothing here is a save. Clearing caches can make the next game start slower once.")
                }
            }
            if !model.everything.isEmpty {
                Section {
                    ForEach(model.everything) { rowView($0) }
                } header: { Text("Everything on this device") } footer: {
                    Text("Every folder Madeira keeps on this device, biggest first. Madeira's own app size and iOS's System Data are not counted. Folders on an external drive count on the drive.")
                }
            }
        }
    }

    private var summary: some View {
        Section {
            HStack {
                Text("Madeira uses")
                Spacer()
                if model.scanned || model.deviceTotal > 0 {
                    Text(ByteCountFormatter.string(fromByteCount: model.deviceTotal, countStyle: .file)).foregroundStyle(.secondary)
                } else { ProgressView() }
            }
            .onAppear { if !model.scanned { model.refresh() } }
            if let capacity = model.capacity {
                HStack {
                    Text("Free on this device")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: capacity.free, countStyle: .file)).foregroundStyle(.secondary)
                }
            }
            if model.externalTotal > 0 {
                HStack {
                    Text("On external drives")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: model.externalTotal, countStyle: .file)).foregroundStyle(.secondary)
                }
            }
            if model.running {
                HStack(spacing: 8) { ProgressView(); Text(model.progressText).font(.footnote).foregroundStyle(.secondary) }
                Button("Stop") { model.cancel() }.padRow("st-stop") { model.cancel() }
            } else {
                if StorageUsage.deleteEnabled {
                    if model.selecting {
                        Button("Done") { model.endSelecting() }.padRow("st-done") { model.endSelecting() }
                    } else {
                        Button("Select") { model.beginSelecting() }.padRow("st-select") { model.beginSelecting() }
                    }
                }
                Button("Refresh sizes") { model.refresh() }.disabled(model.scanning).padRow("st-refresh") { model.refresh() }
                if model.scanning {
                    HStack(spacing: 8) { ProgressView(); Text("Measuring…").font(.footnote).foregroundStyle(.secondary) }
                }
            }
        } header: { Text("What is using storage") }
    }

    private var deleteBar: some View {
        Section {
            Button(role: .destructive) { if model.ask(model.selectedRows) { open(.storageDelete) } } label: {
                Text(String(format: L("Delete %d selected (%@)"), model.selected.count, model.selectedBytesText))
            }
            .padRow("st-delete") { if model.ask(model.selectedRows) { open(.storageDelete) } }
        }
    }

    private var reportSection: some View {
        Section {
            ForEach(model.report, id: \.self) { Text($0).font(.footnote) }
            Button("Dismiss") { model.report = [] }.padRow("st-dismiss") { model.report = [] }
        } header: { Text("Last cleanup") }
    }

    /// Where Files shows this row's folder, or nil.
    private func filesURL(_ row: StorageRow) -> URL? {
        guard StorageUsage.filesLinkEnabled, !row.external, let rel = row.filesPath else { return nil }
        let full = LibraryModel.documents.path + "/" + rel
        guard let encoded = full.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return nil }
        return URL(string: "shareddocuments://" + encoded)
    }

    private func openInFiles(_ row: StorageRow) {
        guard let url = filesURL(row) else { return }
        LogStore.shared.log("[storage] open in Files: \(row.filesPath ?? "")")
        UIApplication.shared.open(url, options: [:]) { opened in
            if !opened { LogStore.shared.log("[storage] Files did not open \(row.filesPath ?? "")") }
        }
    }

    private func tap(_ row: StorageRow) {
        if model.selecting { model.toggle(row) }
        else if row.deletable && StorageUsage.deleteEnabled && !model.running { if model.ask([row]) { open(.storageDelete) } }
        else if filesURL(row) != nil { openInFiles(row) }
    }

    /// A row does something on tap when it is selectable, deletable, or has a folder to show in Files.
    private func tappable(_ row: StorageRow) -> Bool {
        (model.selecting && row.deletable) || (row.deletable && StorageUsage.deleteEnabled) || filesURL(row) != nil
    }

    private func rowLabel(_ row: StorageRow) -> some View {
        HStack(spacing: 10) {
            if model.selecting && row.deletable {
                Image(systemName: model.selected.contains(row.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(model.selected.contains(row.id) ? Color.accentColor : Color.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title).foregroundStyle(.primary)
                if !row.detail.isEmpty { Text(row.detail).font(.footnote).foregroundStyle(.secondary).lineLimit(2) }
            }
            Spacer(minLength: 8)
            if let bytes = row.bytes {
                Text(ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)).foregroundStyle(.secondary)
            } else if model.scanning {
                ProgressView()
            } else {
                Text("–").foregroundStyle(.secondary)
            }
            // A row that only opens Files says so; one that deletes keeps Files on its swipe and long press.
            if !row.deletable && filesURL(row) != nil && !model.selecting {
                Image(systemName: "arrow.up.forward.app").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder private func rowView(_ row: StorageRow) -> some View {
        if StorageUsage.filesLinkEnabled && !tappable(row) {
            // Nothing to do on tap (not deletable, not in Documents): a plain row, not a button.
            rowLabel(row)
        } else {
            Button { tap(row) } label: { rowLabel(row) }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    if row.deletable && StorageUsage.deleteEnabled && !model.running && !model.selecting {
                        Button(role: .destructive) { if model.ask([row]) { open(.storageDelete) } } label: { Label("Delete", systemImage: "trash") }
                    }
                }
                .swipeActions(edge: .leading) {
                    if filesURL(row) != nil && !model.selecting {
                        Button { openInFiles(row) } label: { Label("Files", systemImage: "folder") }.tint(.blue)
                    }
                }
                .contextMenu {
                    if filesURL(row) != nil {
                        Button { openInFiles(row) } label: { Label("Show in Files", systemImage: "folder") }
                        Button { UIPasteboard.general.string = ((Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? "Madeira") + "/" + (row.filesPath ?? "") } label: { Label("Copy Files path", systemImage: "doc.on.doc") }
                    }
                }
                .padRow("st-" + row.id) { tap(row) }
        }
    }
}

// MARK: - Confirm sheet

struct StorageConfirmSheet: View {
    @ObservedObject private var model = StorageModel.shared
    @Environment(\.dismiss) private var dismiss
    /// Saves found for the games in this sheet (folders, bytes); nil while looking.
    @State private var saves: (count: Int, bytes: Int64)?

    private var rows: [StorageRow] { model.pending }
    private var hasGames: Bool { rows.contains { $0.isGame } }
    private var hasPrograms: Bool { rows.contains { $0.isProgram } }
    private var total: String {
        let known = rows.compactMap(\.bytes).reduce(0, +)
        let text = ByteCountFormatter.string(fromByteCount: known, countStyle: .file)
        return rows.contains { $0.bytes == nil } ? String(format: L("At least %@"), text) : text
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(rows) { row in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.title)
                                // What the row is, in full (the list cuts it to two lines).
                                if !row.detail.isEmpty && !row.isGame { Text(row.detail).font(.footnote).foregroundStyle(.secondary) }
                            }
                            Spacer()
                            if let bytes = row.bytes { Text(ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)).foregroundStyle(.secondary) }
                        }
                    }
                } header: {
                    Text(rows.count == 1 ? L("Delete this?") : String(format: L("Delete these %d?"), rows.count))
                } footer: {
                    Text(String(format: L("Frees about %@."), total) + " " + L("Deleted here is gone for good: it does not go to Recently Deleted."))
                }
                if hasPrograms {
                    Section {
                        Toggle("Also delete the program's folder", isOn: $model.alsoFiles)
                    } footer: {
                        Text("Off: only the library entry goes. A folder shared with another game, or a Windows folder, is never deleted.")
                    }
                }
                if hasGames {
                    Section {
                        Toggle("Also delete saves and settings", isOn: $model.alsoSaves)
                    } footer: {
                        Text(savesFooter)
                    }
                }
                Section {
                    Button(role: .destructive) { dismiss(); DispatchQueue.main.async { model.deleteNow() } } label: {
                        Text(rows.count == 1 ? L("Delete") : String(format: L("Delete %d items"), rows.count)).frame(maxWidth: .infinity)
                    }
                    .padRow("st-confirm") { dismiss(); DispatchQueue.main.async { model.deleteNow() } }
                    Button("Cancel", role: .cancel) { model.pending = []; dismiss() }.padRow("st-cancel") { model.pending = []; dismiss() }
                }
            }
            .navigationTitle("Delete")
            .navigationBarTitleDisplayMode(.inline)
            .task { await findSaves() }
        }
    }

    private var savesFooter: String {
        guard let saves else { return L("Looking for saves…") }
        if saves.count == 0 { return L("No saves were found by name. Saves stay unless you turn this on, and nothing is guessed.") }
        let size = ByteCountFormatter.string(fromByteCount: saves.bytes, countStyle: .file)
        return String(format: L("Found %d save and settings folders (%@), matched by the game's exact name. Off keeps them."), saves.count, size)
    }

    private func findSaves() async {
        let names = rows.filter { $0.isGame }.flatMap(\.names)
        guard !names.isEmpty else { return }
        let found = await Task.detached(priority: .utility) { () -> (Int, Int64) in
            let drive = LibraryModel.drive
            let folders = SaveFinder.folders(names: names, drive: drive)
            return (folders.count, SaveFinder.bytes(of: folders))
        }.value
        saves = (found.0, found.1)
    }
}
