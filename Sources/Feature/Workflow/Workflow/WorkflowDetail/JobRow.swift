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
    @State private var selectedStep: JobStepItem?
    @State private var healthStatus: JobRowStatus = .unknown

    var body: some View {
        VStack(spacing: 0) {
            // 头部信息行 - 左对齐 Grid
            jobInfoGrid

            Divider()
                .padding(.vertical, 8)

            // 步骤行
            HStack(spacing: 12) {
                Text("Steps")
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
                    .frame(width: 50, alignment: .leading)

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

    private var jobInfoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.fixed(140), alignment: .leading),
            GridItem(.fixed(200), alignment: .leading),
            GridItem(.fixed(100), alignment: .leading),
            GridItem(.fixed(100), alignment: .leading),
            GridItem(.fixed(80), alignment: .leading)
        ], spacing: 8) {
            // ID
            VStack(alignment: .leading, spacing: 2) {
                Text("ID")
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
                Text(String(job.id.prefix(8)))
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
            }

            // Target
            VStack(alignment: .leading, spacing: 2) {
                Text("Target")
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
                Text(targetText)
                    .font(.caption)
                    .foregroundColor(.CardFrontground)
                    .lineLimit(1)
            }

            // Created At
            VStack(alignment: .leading, spacing: 2) {
                Text("Created")
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
                Text(formatDate(job.createdAt))
                    .font(.caption)
                    .foregroundColor(.CardFrontground)
            }

            // Duration
            VStack(alignment: .leading, spacing: 2) {
                Text("Duration")
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
                Text(formatDuration)
                    .font(.caption)
                    .foregroundColor(.CardFrontground)
            }

            // Status
            VStack(alignment: .leading, spacing: 2) {
                Text("Status")
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(jobStatusColor(job.status))
                        .frame(width: 6, height: 6)
                    Text(job.status)
                        .font(.caption)
                        .foregroundColor(jobStatusColor(job.status))
                }
            }
        }
    }

    private var targetText: String {
        let entries = job.info.jobTarget.entries
        let parentID = job.info.jobTarget.parentEntryID
        if !entries.isEmpty {
            return entries.joined(separator: ", ")
        }
        return parentID.isEmpty ? "-" : String(parentID.prefix(8))
    }

    private var formatDuration: String {
        guard job.startAt > Date.distantPast else { return "-" }
        let duration = job.finishAt.timeIntervalSince(job.startAt)
        if duration < 0 { return "-" }
        if duration < 60 {
            return String(format: "%.0fs", duration)
        } else if duration < 3600 {
            return String(format: "%.0fm", duration / 60)
        } else {
            return String(format: "%.1fh", duration / 3600)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var stepsView: some View {
        HStack(spacing: 12) {
            ForEach(job.stepItems) { step in
                stepCircle(step)
            }
        }
    }

    @ViewBuilder
    private func stepCircle(_ step: JobStepItem) -> some View {
        VStack(spacing: 4) {
            Image(systemName: stepStatusIcon(step.status))
                .font(.system(size: 16))
                .foregroundColor(stepColor(step.status))
                .frame(width: 24, height: 24)
                .onTapGesture {
                    selectedStep = step
                }
                .popover(isPresented: Binding(
                    get: { selectedStep?.id == step.id },
                    set: { if !$0 { selectedStep = nil } }
                )) {
                    stepPopoverContent(step)
                        .frame(width: 200)
                        .padding(12)
                }
        }
    }

    private func stepPopoverContent(_ step: JobStepItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(step.name)
                .font(.caption.bold())
                .foregroundColor(.primary)

            Text(step.message.isEmpty ? "No message" : step.message)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func stepStatusIcon(_ status: String) -> String {
        switch status {
        case "succeed": return "checkmark.circle.fill"
        case "failed", "error": return "xmark.circle.fill"
        default: return "circle.fill"
        }
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
            return
        }

        let successCount = jobs.filter { $0.status == "succeed" }.count
        let successRate = Double(successCount) / Double(total)

        if successRate > 0.7 {
            healthStatus = .healthy
        } else if successRate < 0.3 {
            healthStatus = .critical
        } else {
            healthStatus = .warning
        }
    }
}
