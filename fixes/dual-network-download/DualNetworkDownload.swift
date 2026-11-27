import Foundation
import Network

/// Fetches one URL over a chosen interface (Wi-Fi or cellular) with Network.framework,
/// so depot chunks can be split across both links. URLSession cannot pin an interface.
/// OFF by default (uses cellular data): Settings key "dualNetworkDownload" or env MADEIRA_DUAL_NETWORK_DOWNLOAD=1.
enum DualNetworkDownload {
    static var enabled: Bool {
        if UserDefaults.standard.bool(forKey: "dualNetworkDownload") { return true }
        return ProcessInfo.processInfo.environment["MADEIRA_DUAL_NETWORK_DOWNLOAD"] == "1"
    }

    private final class Stats: @unchecked Sendable {
        let lock = NSLock()
        var inflight: [NWInterface.InterfaceType: Int] = [.wifi: 0, .cellular: 0]
        var speed: [NWInterface.InterfaceType: Double] = [.wifi: 1, .cellular: 1] // bytes/s EMA
        var cellularFailures = 0
    }
    private static let stats = Stats()

    private static let timeout: TimeInterval = 30
    private static let maxResponse = 64 * 1024 * 1024

    /// The Content-Length among the response header lines, or nil if absent or not a number in range.
    static func contentLength(_ lines: [String]) -> Int? {
        let name = "content-length:"
        guard let line = lines.last(where: { $0.lowercased().hasPrefix(name) }),
              let n = Int(line.dropFirst(name.count).trimmingCharacters(in: .whitespaces)),
              n >= 0, n <= maxResponse else { return nil }
        return n
    }

    /// Picks the link with the lowest (inflight+1)/speed, so the faster link gets more chunks.
    private static func pick() -> NWInterface.InterfaceType {
        stats.lock.lock(); defer { stats.lock.unlock() }
        if stats.cellularFailures >= 5 { return .wifi }   // cellular unusable: stop trying
        let w = Double(stats.inflight[.wifi]! + 1) / stats.speed[.wifi]!
        let c = Double(stats.inflight[.cellular]! + 1) / stats.speed[.cellular]!
        return w <= c ? .wifi : .cellular
    }

    /// Throws on any problem; the caller falls back to the normal URLSession path.
    static func fetch(_ url: URL) async throws -> Data {
        let link = pick()
        stats.lock.lock(); stats.inflight[link]! += 1; stats.lock.unlock()
        let start = Date()
        defer { stats.lock.lock(); stats.inflight[link]! -= 1; stats.lock.unlock() }
        do {
            let data = try await get(url, over: link)
            let rate = Double(data.count) / max(0.05, Date().timeIntervalSince(start))
            stats.lock.lock(); stats.speed[link] = stats.speed[link]! * 0.8 + rate * 0.2; stats.lock.unlock()
            return data
        } catch {
            if link == .cellular { stats.lock.lock(); stats.cellularFailures += 1; stats.lock.unlock() }
            throw error
        }
    }

    private static func get(_ url: URL, over link: NWInterface.InterfaceType) async throws -> Data {
        guard let host = url.host else { throw URLError(.badURL) }
        let tls = url.scheme == "https"
        let port = NWEndpoint.Port(rawValue: UInt16(url.port ?? (tls ? 443 : 80)))!
        let params = tls ? NWParameters(tls: .init(), tcp: .init()) : NWParameters.tcp
        params.requiredInterfaceType = link
        let conn = NWConnection(host: NWEndpoint.Host(host), port: port, using: params)
        // A stalled connect or receive is cancelled, so the caller falls back to URLSession.
        let watchdog = DispatchWorkItem { conn.cancel() }
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: watchdog)
        defer { watchdog.cancel(); conn.cancel() }
        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            var done = false
            conn.stateUpdateHandler = { s in
                guard !done else { return }
                switch s {
                case .ready: done = true; c.resume()
                case .failed(let e): done = true; c.resume(throwing: e)
                case .waiting(let e): done = true; c.resume(throwing: e) // e.g. no cellular route
                case .cancelled: done = true; c.resume(throwing: URLError(.timedOut))
                default: break
                }
            }
            conn.start(queue: .global(qos: .userInitiated))
        }
        let parts = URLComponents(url: url, resolvingAgainstBaseURL: true)
        var path = parts?.percentEncodedPath ?? ""
        if path.isEmpty { path = "/" }
        if let q = parts?.percentEncodedQuery { path += "?" + q }
        let req = "GET \(path) HTTP/1.1\r\nHost: \(host)\r\nConnection: close\r\nAccept: */*\r\n\r\n"
        try await send(conn, Data(req.utf8))
        var buf = Data()
        var bodyStart: Int?
        var length = -1
        while true {
            let (chunk, eof) = try await receive(conn)
            buf.append(chunk)
            guard buf.count <= maxResponse + 65536 else { throw URLError(.dataLengthExceedsMaximum) }
            if bodyStart == nil, let r = buf.range(of: Data("\r\n\r\n".utf8)) {
                let head = String(decoding: buf[..<r.lowerBound], as: UTF8.self)
                let lines = head.components(separatedBy: "\r\n")
                let status = Int(lines[0].split(separator: " ").dropFirst().first ?? "") ?? 0
                guard (200...299).contains(status) else { throw SteamError.contentHTTP(status) }
                if lines.contains(where: { $0.lowercased().hasPrefix("transfer-encoding") }) { throw URLError(.cannotParseResponse) }
                guard let n = contentLength(lines) else { throw URLError(.cannotParseResponse) }
                length = n
                bodyStart = r.upperBound
            }
            if let s = bodyStart, length >= 0, buf.count - s >= length { return buf.subdata(in: s..<(s + length)) }
            if eof { throw URLError(.networkConnectionLost) }
        }
    }

    private static func send(_ c: NWConnection, _ d: Data) async throws {
        try await withCheckedThrowingContinuation { (k: CheckedContinuation<Void, Error>) in
            c.send(content: d, completion: .contentProcessed { e in e == nil ? k.resume() : k.resume(throwing: e!) })
        }
    }
    private static func receive(_ c: NWConnection) async throws -> (Data, Bool) {
        try await withCheckedThrowingContinuation { k in
            c.receive(minimumIncompleteLength: 1, maximumLength: 256 * 1024) { data, _, isComplete, e in
                if let e { k.resume(throwing: e) } else { k.resume(returning: (data ?? Data(), isComplete && (data ?? Data()).isEmpty)) }
            }
        }
    }
}
