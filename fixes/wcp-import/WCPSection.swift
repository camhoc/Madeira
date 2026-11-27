import SwiftUI

/// wcp-import: the "Graphics packages" section of a game's Mods page. DRAFT: not compiled.
/// Import a .wcp (DXVK or vkd3d-proton, ARM64EC), then "Use for this game" writes the game's own line; Remove deletes the
/// package and the line. Hidden entirely when env.MADEIRA_WCP_IMPORT = 0.
struct WCPSection: View {
    let game: ModGame
    @State private var picking = false
    @State private var working = false
    @State private var problem: String?
    @State private var packages: [WCPStore.Installed] = WCPStore.installed()
    @State private var config = ""

    var body: some View {
        if WCPProfile.enabled {
            Section {
                ForEach(packages, id: \.name) { p in
                    let key = WCPStore.key(forType: p.meta.type)
                    let using = config.contains("\(key) = \(p.name)")
                    VStack(alignment: .leading, spacing: 6) {
                        Text(verbatim: "\(p.meta.type.uppercased()) \(p.meta.versionName)").font(.headline)
                        HStack {
                            Button(using ? "Stop using" : "Use for this game") { set(key, using ? nil : p.name) }
                                .buttonStyle(.bordered)
                            Button("Remove", role: .destructive) { remove(p) }.buttonStyle(.bordered)
                        }
                    }
                }
                Button { picking = true } label: { Text("Import a .wcp package…").frame(maxWidth: .infinity) }
                    .disabled(working)
                if working { ProgressView() }
                if let problem { Text(problem).foregroundStyle(.red).font(.caption) }
            } header: {
                Text("Graphics packages (experimental)")
            } footer: {
                Text("DXVK or vkd3d-proton as an ARM64EC .wcp. Used only by this game, and only with d3d11 = dxvk or d3d12 = vkd3d set. Nothing in the game's files changes.")
            }
            .onAppear { config = game.readConfig() }
            .sheet(isPresented: $picking) {
                ModDocumentPicker(folder: false) { url in
                    picking = false
                    guard let url else { return }
                    working = true; problem = nil
                    Task.detached {
                        let result = Result { try WCPStore.importPackage(url) }
                        await MainActor.run {
                            working = false
                            if case .failure(let e) = result { problem = WCPStore.message(e) }
                            packages = WCPStore.installed()
                        }
                    }
                }
            }
        }
    }

    private func set(_ key: String, _ name: String?) {
        game.writeConfig(WCPStore.setLine(game.readConfig(), key: key, to: name))
        config = game.readConfig()
    }

    private func remove(_ p: WCPStore.Installed) {
        // This game's line goes too; another game that names the package falls back to the bundle's DLLs (logged).
        let key = WCPStore.key(forType: p.meta.type)
        if game.readConfig().contains("\(key) = \(p.name)") { game.writeConfig(WCPStore.setLine(game.readConfig(), key: key, to: nil)) }
        WCPStore.remove(p.name)
        packages = WCPStore.installed(); config = game.readConfig()
    }
}
