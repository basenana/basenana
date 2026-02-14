//
//  CaptureWindowView.swift
//  Feature
//
//  Window view for capture functionality.
//

import SwiftUI
import Domain

public struct CaptureWindowView: View {
    let data: CaptureData?
    let entryUsecase: EntryUseCaseProtocol?

    public init(data: CaptureData?, entryUsecase: EntryUseCaseProtocol?) {
        self.data = data
        self.entryUsecase = entryUsecase
    }

    public var body: some View {
        if let data = data {
            if StateStore.shared.fsInfo.fsApiReady {
                if let entryUsecase = entryUsecase {
                    let viewModel = CaptureViewModel(store: .shared, entryUsecase: entryUsecase)
                    CaptureContainerView(data: data, viewModel: viewModel)
                } else {
                    ProgressView("Loading...")
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)
                    Text("Please login first")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("You need to login to capture web pages.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 400, height: 300)
            }
        } else {
            EmptyView()
        }
    }
}
