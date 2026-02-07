//
//  QuickInboxView.swift
//  Feature
//
//  Simplified inbox view using background fetch.
//

import SwiftUI
import Domain

public struct QuickInboxView: View {
    @State private var urlInput: String = ""
    @State private var urlTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    private let viewModel: InboxViewModel
    @Binding private var showInboxView: Bool

    public init(viewModel: InboxViewModel, showInboxView: Binding<Bool>) {
        self.viewModel = viewModel
        self._showInboxView = showInboxView
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick Inbox")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("URL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Web URL", text: $urlInput)
                    .textFieldStyle(.squareBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Title (optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Auto-detected from page", text: $urlTitle)
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
                    showInboxView = false
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button {
                    fetchAndUpload()
                } label: {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Fetch & Save")
                    }
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(urlInput.isEmpty || isLoading)
            }
        }
        .padding(30)
        .frame(width: 400)
    }

    private func fetchAndUpload() {
        guard !urlInput.isEmpty else { return }

        isLoading = true
        errorMessage = ""

        viewModel.fetchAndUpload(url: urlInput, title: urlTitle.isEmpty ? nil : urlTitle)

        // Close the sheet after initiating the fetch
        showInboxView = false
    }
}
