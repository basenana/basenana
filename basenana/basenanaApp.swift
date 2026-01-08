import SwiftUI

public struct BasenanaAppMain {
    public init() {}

    public func run() {
        if let app = NSApplication.shared as? NSApplication {
            app.run()
        }
    }
}

public struct basenanaApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1350, minHeight: 750)
        }

        Settings {
            SettingsView()
        }
    }
}
