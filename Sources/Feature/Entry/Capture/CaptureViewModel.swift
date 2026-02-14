//
//  CaptureViewModel.swift
//  Feature
//
//  ViewModel for handling external capture requests from browser extension.
//

import Foundation
import Domain

@Observable
@MainActor
public class CaptureViewModel {
    public enum CaptureState {
        case idle
        case capturing
        case success
        case failed(String)
    }

    public var state: CaptureState = .idle {
        didSet {
            if case .success = state {
                onSuccess?()
            }
        }
    }
    public var url: String = ""
    public var title: String = ""
    public var content: String = ""

    public var onSuccess: (() -> Void)?

    private let store: StateStore
    private let entryUsecase: EntryUseCaseProtocol

    public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }

    public func setData(url: String, title: String, content: String) {
        self.url = url
        self.title = title
        self.content = content
    }

    public func startCapture() {
        // Check if user is logged in
        guard store.fsInfo.fsApiReady else {
            state = .failed("Please login first")
            return
        }

        if content.isEmpty {
            // If no content provided, fetch from URL
            fetchFromURL()
        } else {
            // Save content directly
            saveContent()
        }
    }

    public func reset() {
        state = .idle
        url = ""
        title = ""
        content = ""
    }

    private func fetchFromURL() {
        guard !url.isEmpty else {
            state = .failed("No URL provided")
            return
        }

        state = .capturing

        let useCase = FetchWebPageUseCase(entryUsecase: entryUsecase, setting: store.setting.general)

        store.newBackgroundJob(
            name: "Capturing \(url)",
            job: {
                do {
                    _ = try await useCase.execute(url: self.url, title: self.title.isEmpty ? nil : self.title)
                } catch {
                    Task { @MainActor in
                        self.state = .failed(error.localizedDescription)
                    }
                }
            },
            complete: {
                Task { @MainActor in
                    if case .capturing = self.state {
                        self.state = .success
                    }
                }
            }
        )
    }

    private func saveContent() {
        guard !content.isEmpty else {
            state = .failed("No content to save")
            return
        }

        guard !url.isEmpty else {
            state = .failed("No URL provided")
            return
        }

        state = .capturing

        let useCase = FetchWebPageUseCase(entryUsecase: entryUsecase, setting: store.setting.general)

        store.newBackgroundJob(
            name: "Capturing \(url)",
            job: {
                do {
                    _ = try await useCase.execute(url: self.url, title: self.title.isEmpty ? nil : self.title, html: self.content)
                } catch {
                    Task { @MainActor in
                        self.state = .failed(error.localizedDescription)
                    }
                }
            },
            complete: {
                Task { @MainActor in
                    if case .capturing = self.state {
                        self.state = .success
                    }
                }
            }
        )
    }
}
