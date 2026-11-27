// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2026 ft7t8drgwf-wq
// Madeira Converter Exception: see LICENSE-EXCEPTION.md
//
//  (remote-run-status) The "Will it run?" ratings (run-status.json) as signed data from the Get Help server,
//  so new ratings reach players without a new IPA. Cameron's go Nov 26 2026 ("yes": do it the RemoteRecs way).
//
//  Same channel as RemoteRecs.swift: the same Ed25519 key (SharedConfigs.publicKey / verify), the same Get Help
//  key header, "keep only a file whose signature checks, check it again when read".
//  The body is a run-status.json exactly as the PC script writes it (scripts/make-run-status.py); the server
//  sends it with the signature in the x-madeira-signature header.
//  A downloaded file is used ONLY when it decodes as RunStatusFile and its `generated` date is not older than the
//  bundled file's and not older than the kept one (no going back to older ratings by replay). A kept file older than
//  120 days is not used. Anything wrong: the bundled file, as before.
//  A new file is kept at once and read at the NEXT start (the ratings are read once per start).
//  Off: env.MADEIRA_REMOTE_RUN_STATUS = 0 (Settings > All settings > App & front end). No MadeiraSharedConfigsKey
//  in the build's Info.plist: off. Logs: [remote-run-status] ...
//
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking   // URLRequest/URLSession on Linux (the host check); nothing on iOS
#endif

enum RemoteRunStatus {
    static let enabled = MadeiraConfig.flag("MADEIRA_REMOTE_RUN_STATUS")
    static let refreshEvery: TimeInterval = 3600
    static let expireAfterDays = 120
    static let maxBytes = 2_000_000

    private static var folder: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RemoteRunStatus", isDirectory: true)
    }
    /// One file, written in one atomic step: the signature on the first line, then the signed body as received.
    private static var signedURL: URL { folder.appendingPathComponent("run-status.signed") }

    private static func parse(_ data: Data) -> RunStatusFile? {
        guard data.count <= maxBytes, let file = try? JSONDecoder().decode(RunStatusFile.self, from: data),
              file.version == 1, !file.games.isEmpty else { return nil }
        return file
    }
    /// `generated` is "YYYY-MM-DD" (the PC script's date): a plain date. Anything else: nil.
    static func generatedDate(_ text: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX"); f.timeZone = TimeZone(identifier: "UTC"); f.dateFormat = "yyyy-MM-dd"
        return f.date(from: String(text.prefix(10)))
    }

    private static func keptParts() -> (String, Data)? {
        guard let all = try? Data(contentsOf: signedURL), let nl = all.firstIndex(of: 0x0A),
              let sig = String(data: all[..<nl], encoding: .utf8) else { return nil }
        return (sig, all[all.index(after: nl)...])
    }
    private static func keptFile() -> RunStatusFile? {
        guard let (sig, data) = keptParts() else { return nil }
        guard SharedConfigs.verify(data, signature: sig) else {
            LogStore.shared.log("[remote-run-status] kept file failed its signature check; not used")
            return nil
        }
        return parse(data)
    }

    /// The kept ratings when they are usable and not older than `bundled`; nil otherwise (use the bundled file).
    static func newerThan(_ bundled: RunStatusFile?) -> RunStatusFile? {
        guard enabled, !SharedConfigs.publicKey.isEmpty, let kept = keptFile(),
              let made = generatedDate(kept.generated) else { return nil }
        let age = Int(Date().timeIntervalSince(made) / 86400)
        if age > expireAfterDays {
            LogStore.shared.log("[remote-run-status] kept file is \(age) days old: not used (bundled ratings)")
            return nil
        }
        if let bundled, let b = generatedDate(bundled.generated), made < b {
            LogStore.shared.log("[remote-run-status] kept file is older than the bundled one: not used")
            return nil
        }
        LogStore.shared.log("[remote-run-status] using kept ratings (data \(kept.generated))")
        return kept
    }

    /// Asks the Get Help server for the newest ratings, at most every `refreshEvery`. Does not wait.
    static func refresh() {
        guard enabled, !SharedConfigs.publicKey.isEmpty, GetHelp.enabled, let key = GetHelp.key else { return }
        let last = UserDefaults.standard.double(forKey: "remote-run-status-checked")
        let now = Date().timeIntervalSince1970
        guard now - last >= refreshEvery else { return }
        UserDefaults.standard.set(now, forKey: "remote-run-status-checked")
        var request = URLRequest(url: GetHelpCore.server.appendingPathComponent("shared/run-status"), timeoutInterval: 20)
        request.setValue(key, forHTTPHeaderField: "x-madeira-key")
        URLSession.shared.dataTask(with: request) { data, response, _ in
            let http = response as? HTTPURLResponse
            guard http?.statusCode == 200, let data, let sig = http?.value(forHTTPHeaderField: "x-madeira-signature"),
                  SharedConfigs.verify(data, signature: sig), let new = parse(data),
                  let newDate = generatedDate(new.generated) else {
                LogStore.shared.log("[remote-run-status] newest file: not used (status \(http?.statusCode ?? 0))")
                return
            }
            if let kept = keptFile(), let keptDate = generatedDate(kept.generated), newDate < keptDate {
                LogStore.shared.log("[remote-run-status] newest file is older than the kept one; refused")
                return
            }
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                try (Data(sig.utf8) + Data([0x0A]) + data).write(to: signedURL, options: .atomic)
                LogStore.shared.log("[remote-run-status] newest ratings kept (data \(new.generated), \(new.games.count) games): used from the next start")
            } catch {
                LogStore.shared.log("[remote-run-status] could not keep the file: \(error.localizedDescription)", level: .error)
            }
        }.resume()
    }
}
