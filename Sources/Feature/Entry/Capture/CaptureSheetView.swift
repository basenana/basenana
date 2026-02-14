//
//  CaptureSheetView.swift
//  Feature
//
//  Sheet view for capturing web pages from sidebar.
//

import SwiftUI
import Domain

public struct CaptureSheetView: View {
    @Binding public var captureUrl: String
    @Binding public var captureTitle: String
    @Binding public var showCapture: Bool

    let store: StateStore
    let entryUsecase: EntryUseCaseProtocol

    @State private var urlInput: String = ""
    @State private var titleInput: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    public init(captureUrl: Binding<String>, captureTitle: Binding<String>, showCapture: Binding<Bool>, store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self._captureUrl = captureUrl
        self._captureTitle = captureTitle
        self._showCapture = showCapture
        self.store = store
        self.entryUsecase = entryUsecase
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Capture Web Page")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("URL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("https://...", text: $urlInput)
                    .textFieldStyle(.squareBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Title (optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Auto-detected from page", text: $titleInput)
                    .textFieldStyle(.squareBorder)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    showCapture = false
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button {
                    captureWebPage()
                } label: {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Capture")
                    }
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(urlInput.isEmpty || isLoading)
            }
        }
        .padding(30)
        .frame(width: 400)
    }

    private func captureWebPage() {
        guard !urlInput.isEmpty else { return }

        isLoading = true
        errorMessage = ""

        let viewModel = InboxViewModel(store: store, entryUsecase: entryUsecase)
        viewModel.fetchAndUpload(url: urlInput, title: titleInput.isEmpty ? nil : titleInput)

        // Close the sheet after initiating the fetch
        showCapture = false
    }
}
