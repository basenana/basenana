import SwiftUI

@main
struct basenanaApp: App {
    init() {}

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1350, minHeight: 750)
        }

        WindowGroup(for: String.self) { $documentUri in
            if let uri = documentUri {
                DocumentWindowView(uri: uri)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)

        Settings {
            SettingsView()
        }
    }
}
