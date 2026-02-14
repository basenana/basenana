import SwiftUI
import Feature
import Domain
import Data
import AppKit

extension Notification.Name {
    static let captureURL = Notification.Name("captureURL")
    static let closeCaptureWindow = Notification.Name("closeCaptureWindow")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            if url.scheme == "basenana" && url.host == "capture" {
                DispatchQueue.main.async {
                    CaptureState.shared.pendingURL = url
                    CaptureState.shared.shouldShowCaptureWindow = true
                }
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

@main
struct basenanaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @SwiftUI.Environment(\.openWindow) private var openCaptureWindow
    @StateObject private var captureState = CaptureState.shared

    @State private var entryUsecase: EntryUseCaseProtocol?

    var body: some Scene {
        Window("Basenana", id: "main") {
            ContentView()
                .frame(minWidth: 1350, minHeight: 750)
                .onReceive(captureState.$pendingURL) { url in
                    if let url = url {
                        handleCaptureURL(url)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .closeCaptureWindow)) { _ in
                    captureState.reset()
                }
        }

        Window("Capture", id: "capture") {
            CaptureContentView(
                captureState: captureState,
                entryUsecase: entryUsecase
            )
            .onAppear {
                if entryUsecase == nil {
                    let container = DIContainer(state: .shared)
                    entryUsecase = container.c.resolve(EntryUseCaseProtocol.self)
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 500, height: 400)

        WindowGroup(for: String.self) { $documentUri in
            if let uri = documentUri?.replacingOccurrences(of: "document:", with: "") {
                DocumentWindowView(uri: uri)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)

        Settings {
            SettingsView()
        }
    }

    private func handleCaptureURL(_ url: URL) {
        guard url.scheme == "basenana",
              url.host == "capture" else {
            print("[Capture] URL scheme or host not match")
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            print("[Capture] Failed to parse URL components")
            return
        }

        let urlValue = queryItems.first(where: { $0.name == "url" })?.value ?? ""
        let titleValue = queryItems.first(where: { $0.name == "title" })?.value ?? ""
        let contentValue = queryItems.first(where: { $0.name == "content" })?.value ?? ""

        let data = CaptureData(
            url: urlValue,
            title: titleValue,
            content: contentValue
        )
        captureState.captureData = data
        captureState.pendingURL = nil

        openCaptureWindow(id: "capture")
    }
}
