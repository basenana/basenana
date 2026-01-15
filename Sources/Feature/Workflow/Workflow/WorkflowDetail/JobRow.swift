//
//  JobRow.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import Domain
import Styleguide


enum JobRowStatus {
    case healthy, warning, critical, unknown

    var color: Color {
        switch self {
        case .healthy: return .WorkflowSuccess
        case .warning: return .WorkflowPending
        case .critical: return .WorkflowFailed
        case .unknown: return .gray
        }
    }
}


struct JobRow: View {
    let job: JobItem
    let viewModel: WorkflowDetailViewModel

    @State private var isHovered = false
    @State private var hoveredStep: JobStepItem?
    @State private var healthStatus: JobRowStatus = .unknown
    @State private var successRateText: String = "Loading..."

    var body: some View {
        HStack(spacing: 12) {
            Text(String(job.id.prefix(8)))
                .font(.caption.monospaced())
                .foregroundColor(.secondary)

            Text(job.triggerReason)
                .font(.caption)
                .foregroundColor(.WorkflowTextSecondary)
                .lineLimit(1)

            Spacer()

            stepsView

            Spacer()

            HStack(spacing: 8) {
                Text(job.status)
                    .font(.caption)
                    .foregroundColor(jobStatusColor(job.status))

                Circle()
                    .fill(healthStatus.color)
                    .frame(width: 8, height: 8)

                if canPause {
                    actionButton(title: "Pause", action: { Task { await viewModel.pauseJob(jobId: job.id) } })
                }
                if canResume {
                    actionButton(title: "Resume", action: { Task { await viewModel.resumeJob(jobId: job.id) } })
                }
                if canCancel {
                    actionButton(title: "Cancel", action: { Task { await viewModel.cancelJob(jobId: job.id) } })
                }
            }
        }
        .padding(12)
        .background(isHovered ? Color.secondaryBackground : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            isHovered = hovering
        }
        .task {
            await loadHealthData()
        }
    }

    private var stepsView: some View {
        HStack(spacing: 6) {
            ForEach(job.stepItems) { step in
                stepCircle(step)
            }
        }
    }

    @ViewBuilder
    private func stepCircle(_ step: JobStepItem) -> some View {
        ZStack {
            Circle()
                .fill(stepColor(step.status))
                .frame(width: 14, height: 14)

            if hoveredStep?.id == step.id {
                GeometryReader { geometry in
                    Text(stepTooltipText(step))
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.9))
                        .cornerRadius(6)
                        .offset(y: -geometry.size.height - 30)
                        .position(x: geometry.size.width / 2)
                }
                .frame(width: 120, height: 60)
            }
        }
        .frame(width: 14, height: 14)
        .onHover { hovering in
            if hovering {
                hoveredStep = step
            } else if hoveredStep?.id == step.id {
                hoveredStep = nil
            }
        }
    }

    private func stepTooltipText(_ step: JobStepItem) -> String {
        "\(step.name): \(step.status)\n\(step.message)"
    }

    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.WorkflowPending)
        }
        .buttonStyle(.plain)
    }

    private var canPause: Bool {
        job.status == "running" || job.status == "initializing"
    }

    private var canResume: Bool {
        job.status == "pausing" || job.status == "paused"
    }

    private var canCancel: Bool {
        job.status == "running" || job.status == "initializing" || job.status == "pausing" || job.status == "paused"
    }

    private func stepColor(_ status: String) -> Color {
        switch status {
        case "succeed": return .WorkflowSuccess
        case "failed", "error": return .WorkflowFailed
        default: return .gray
        }
    }

    private func jobStatusColor(_ status: String) -> Color {
        switch status {
        case "succeed": return .WorkflowSuccess
        case "failed", "error": return .WorkflowFailed
        case "running", "initializing", "pausing": return .WorkflowPending
        case "paused", "canceled": return .gray
        default: return .gray
        }
    }

    private func loadHealthData() async {
        do {
            let jobs = try await viewModel.usecase.listWorkflowJobs(
                workflow: viewModel.workflowID,
                page: 1,
                pageSize: 10,
                sort: "created_at",
                order: "desc"
            )
            let jobItems = jobs.map { JobItem(job: $0) }
            updateHealthStatus(from: jobItems)
        } catch {
            updateHealthStatus(from: [])
        }
    }

    private func updateHealthStatus(from jobs: [JobItem]) {
        let total = jobs.count
        guard total > 0 else {
            healthStatus = .healthy
            successRateText = "100%"
            return
        }

        let successCount = jobs.filter { $0.status == "succeed" }.count
        let successRate = Double(successCount) / Double(total)
        let rate = Int(successRate * 100)
        successRateText = "\(rate)%"

        if successRate > 0.7 {
            healthStatus = .healthy
        } else if successRate < 0.3 {
            healthStatus = .critical
        } else {
            healthStatus = .warning
        }
    }
}
