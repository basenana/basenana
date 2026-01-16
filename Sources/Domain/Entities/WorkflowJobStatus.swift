//
//  WorkflowJobStatus.swift
//  Domain
//
//  Created by Hypo on 2025/1/17.
//

import Foundation

public enum WorkflowJobStatus: String, CaseIterable {
    case initializing
    case running
    case pausing
    case paused
    case succeed
    case failed
    case canceled
    case error

    public init(rawValue: String) {
        switch rawValue.lowercased() {
        case "initializing": self = .initializing
        case "running": self = .running
        case "pausing": self = .pausing
        case "paused": self = .paused
        case "succeed", "success": self = .succeed
        case "failed": self = .failed
        case "canceled", "cancelled": self = .canceled
        case "error": self = .error
        default: self = .running
        }
    }
}

extension WorkflowJobStatus: Sendable {}
