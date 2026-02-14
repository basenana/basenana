//
//  CaptureContainerView.swift
//  Feature
//
//  Container view for Capture window that resolves dependencies.
//

import SwiftUI
import Domain

// Notification for closing capture window and restoring main window
extension Notification.Name {
    static let closeCaptureWindow = Notification.Name("closeCaptureWindow")
}

public struct CaptureContainerView: View {
    let data: CaptureData
    let viewModel: CaptureViewModel
    @Environment(\.dismissWindow) private var dismissWindow

    public init(data: CaptureData, viewModel: CaptureViewModel) {
        self.data = data
        self.viewModel = viewModel
    }

    public var body: some View {
        CaptureView(viewModel: viewModel) {
            // Close capture window
            dismissWindow(id: "capture")
            // Notify to reset capture state and restore main window
            NotificationCenter.default.post(name: .closeCaptureWindow, object: nil)
        }
        .onAppear {
            viewModel.setData(url: data.url, title: data.title, content: data.content)
            // Auto-close on success
            viewModel.onSuccess = {
                dismissWindow(id: "capture")
                NotificationCenter.default.post(name: .closeCaptureWindow, object: nil)
            }
        }
    }
}
