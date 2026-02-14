//
//  CaptureContentView.swift
//  Feature
//
//  Content view for capture window.
//

import SwiftUI
import Domain

public struct CaptureContentView: View {
    @ObservedObject var captureState: CaptureState
    let entryUsecase: EntryUseCaseProtocol?

    public init(captureState: CaptureState, entryUsecase: EntryUseCaseProtocol?) {
        self.captureState = captureState
        self.entryUsecase = entryUsecase
    }

    public var body: some View {
        CaptureWindowView(
            data: captureState.captureData,
            entryUsecase: entryUsecase
        )
    }
}
