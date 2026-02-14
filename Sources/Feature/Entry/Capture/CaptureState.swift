//
//  CaptureState.swift
//  Feature
//
//  Shared state for capture window communication.
//

import Foundation
import SwiftUI

public class CaptureState: ObservableObject {
    public static let shared = CaptureState()
    @Published public var pendingURL: URL?
    @Published public var shouldShowCaptureWindow: Bool = false
    @Published public var captureData: CaptureData?

    private init() {}

    public func reset() {
        pendingURL = nil
        shouldShowCaptureWindow = false
        captureData = nil
    }
}
