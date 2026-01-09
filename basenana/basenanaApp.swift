import SwiftUI

@main
struct basenanaApp: App {
    init() {}

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1350, minHeight: 750)
        }

        Settings {
            SettingsView()
        }
    }
}
