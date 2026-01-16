//
//  JobStatus.swift
//  Workflow
//
//  Created by Hypo on 2025/1/16.
//

import Foundation
import SwiftUI

enum JobStatus {
    case initializing
    case running
    case pausing
    case paused
    case succeed
    case failed
    case canceled

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "initializing": self = .initializing
        case "running": self = .running
        case "pausing": self = .pausing
        case "paused": self = .paused
        case "succeed", "success": self = .succeed
        case "failed": self = .failed
        case "canceled", "cancelled": self = .canceled
        default: self = .running
        }
    }

    var rawValue: String {
        switch self {
        case .initializing: return "initializing"
        case .running: return "running"
        case .pausing: return "pausing"
        case .paused: return "paused"
        case .succeed: return "succeed"
        case .failed: return "failed"
        case .canceled: return "canceled"
        }
    }

    var displayName: String {
        switch self {
        case .initializing: return "Initializing"
        case .running: return "Running"
        case .pausing: return "Pausing"
        case .paused: return "Paused"
        case .succeed: return "Succeed"
        case .failed: return "Failed"
        case .canceled: return "Canceled"
        }
    }

    var color: Color {
        switch self {
        case .succeed: return .WorkflowSuccess
        case .failed: return .WorkflowFailed
        case .running, .initializing, .pausing: return .WorkflowPending
        case .paused, .canceled: return .gray
        }
    }
}

enum JobStepStatus {
    case pending
    case running
    case succeed
    case failed
    case error

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "pending": self = .pending
        case "running": self = .running
        case "succeed", "success": self = .succeed
        case "failed": self = .failed
        case "error": self = .error
        default: self = .pending
        }
    }

    var rawValue: String {
        switch self {
        case .pending: return "pending"
        case .running: return "running"
        case .succeed: return "succeed"
        case .failed: return "failed"
        case .error: return "error"
        }
    }

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .running: return "Running"
        case .succeed: return "Succeed"
        case .failed: return "Failed"
        case .error: return "Error"
        }
    }
}
