//
//  CaptureView.swift
//  Feature
//
//  View for displaying capture status from browser extension.
//

import SwiftUI
import Domain

public struct CaptureView: View {
    @State private var viewModel: CaptureViewModel
    private let onDismiss: () -> Void

    public init(viewModel: CaptureViewModel, onDismiss: @escaping () -> Void) {
        self._viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundStyle(iconColor)

            Text(statusTitle)
                .font(.title2)
                .fontWeight(.bold)

            if !viewModel.url.isEmpty {
                VStack(alignment: .center, spacing: 4) {
                    Text("URL:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.url)
                        .font(.caption)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
            }

            if !viewModel.title.isEmpty {
                VStack(alignment: .center, spacing: 4) {
                    Text("Title:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.title)
                        .font(.caption)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
            }

            if case .failed(let message) = viewModel.state {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if case .success = viewModel.state {
                Text("Capture completed!")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            HStack {
                Button("Close") {
                    onDismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])

                if case .idle = viewModel.state {
                    Button("Save") {
                        viewModel.startCapture()
                    }
                    .keyboardShortcut(.return, modifiers: [.command])
                    .buttonStyle(.borderedProminent)
                }

                if case .capturing = viewModel.state {
                    ProgressView()
                        .controlSize(.small)
                }

                if case .success = viewModel.state {
                    Button("Done") {
                        onDismiss()
                    }
                    .keyboardShortcut(.return, modifiers: [.command])
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(30)
        .frame(width: 400, height: 350)
    }

    private var iconName: String {
        switch viewModel.state {
        case .idle:
            return "doc.badge.arrow.up"
        case .capturing:
            return "arrow.down.circle"
        case .success:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch viewModel.state {
        case .idle:
            return .secondary
        case .capturing:
            return .blue
        case .success:
            return .green
        case .failed:
            return .red
        }
    }

    private var statusTitle: String {
        switch viewModel.state {
        case .idle:
            return "Ready to Capture"
        case .capturing:
            return "Capturing..."
        case .success:
            return "Captured Successfully"
        case .failed(let message):
            return "Capture Failed: \(message)"
        }
    }
}
