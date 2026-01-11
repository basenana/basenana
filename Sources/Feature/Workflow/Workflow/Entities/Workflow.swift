//
//  Workflow.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import Domain
import SwiftUI

class WorkflowItem: Identifiable, Equatable, Hashable {

    var id: String { info.id }
    var name: String { info.name }

    var info: Workflow

    init(workflow: Workflow) {
        self.info = workflow
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: WorkflowItem, rhs: WorkflowItem) -> Bool {
        return lhs.id == rhs.id
    }

    var healthStatus: HealthStatus {
        switch info.healthScore {
        case 80...100: return .healthy
        case 50..<80: return .warning
        default: return .critical
        }
    }

    var healthScoreText: String {
        "\(info.healthScore)%"
    }

    var executorDisplayName: String {
        if info.executor.isEmpty { return "Unknown" }
        return info.executor
    }

    var queueDisplayName: String {
        if info.queueName.isEmpty { return "Default" }
        return info.queueName
    }

    var updatedText: String {
        relativeTimeString(from: info.updatedAt)
    }

    private func relativeTimeString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        if interval < 604800 { return "\(Int(interval / 86400))d ago" }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

enum HealthStatus {
    case healthy, warning, critical

    var color: Color {
        switch self {
        case .healthy: return .WorkflowSuccess
        case .warning: return .WorkflowPending
        case .critical: return .WorkflowFailed
        }
    }

    var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .warning: return "Warning"
        case .critical: return "Critical"
        }
    }
}
