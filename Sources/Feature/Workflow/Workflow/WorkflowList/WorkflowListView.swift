//
//  WorkflowListView.swift
//  basenana
//
//  Created by Hypo on 2024/6/27.
//

import SwiftUI
import Domain
import Styleguide


enum HealthStatus {
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

public struct WorkflowListView: View {
    @State private var viewModel: WorkflowListViewModel
    @State private var showCreateWorkflow: Bool = false

    public init(viewModel: WorkflowListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            toolbarView

            contentSection
        }
        .task { await viewModel.initWorkflows() }
        .frame(minWidth: 900, minHeight: 600)
        .navigationTitle("Workflow")
        .sheet(isPresented: $showCreateWorkflow) {
            WorkflowCreateView(
                viewModel: WorkflowCreateViewModel(
                    usecase: viewModel.usecase,
                    onCreated: { _ in
                        Task { await viewModel.initWorkflows() }
                    }
                )
            )
        }
    }

    private var toolbarView: some View {
        HStack {
            Button {
                showCreateWorkflow = true
            } label: {
                Label("Create Workflow", systemImage: "plus")
                    .font(.subheadline)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.background)
    }

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.workflows.isEmpty {
            emptyStateView
        } else {
            listView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading workflows...")
                .font(.subheadline)
                .foregroundColor(.WorkflowTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.workflows) { workflow in
                    WorkflowListRow(workflow: workflow, viewModel: viewModel)
                        .id(workflow.id)
                        .onAppear {
                            if workflow.id == viewModel.workflows.last?.id {
                                Task { await viewModel.loadMoreWorkflows() }
                            }
                        }
                        .onTapGesture {
                            gotoDestination(.workflowDetail(workflow: workflow.id))
                        }
                }

                if viewModel.isLoadingMore {
                    loadingMoreView
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.background)
    }

    private var loadingMoreView: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
            Spacer()
        }
    }
}

struct WorkflowListRow: View {
    let workflow: WorkflowRowItem
    let viewModel: WorkflowListViewModel

    @State private var healthStatus: HealthStatus = .unknown
    @State private var successRateText: String = "Loading..."
    @State private var latestJob: JobItem?
    @State private var isHovered = false

    private var healthStatusIcon: String {
        switch healthStatus {
        case .healthy: return "sun.max.fill"
        case .warning: return "sun.rain.fill"
        case .critical: return "cloud.bolt.rain.fill"
        case .unknown: return "moon.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: healthStatusIcon)
                .font(.system(size: 16))
                .foregroundColor(healthStatus.color)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.headline)
                    .foregroundColor(.CardFrontground)

                HStack(spacing: 4) {
                    if let target = latestJob?.target, target != "-" {
                        Text(target)
                            .foregroundColor(.WorkflowTextSecondary)
                            .lineLimit(1)
                    }
                    if let status = latestJob?.status {
                        Text("•")
                        Text(status.displayName)
                            .foregroundColor(status.color)
                    }
                }
                .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(successRateText)
                    .font(.caption)
                    .foregroundColor(healthStatus.color)

                if let createdAt = latestJob?.createdAt {
                    Text(relativeTimeString(from: createdAt))
                        .font(.caption2)
                        .foregroundColor(.WorkflowTextSecondary)
                }
            }
        }
        .padding(12)
        .background(isHovered ? Color.primary.opacity(0.05): Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            isHovered = hovering
        }
        .task {
            await loadHealthData()
        }
    }

    private func loadHealthData() async {
        do {
            let jobs = try await viewModel.usecase.listWorkflowJobs(
                workflow: workflow.id,
                status: [.succeed, .failed],
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
            successRateText = "No jobs"
            latestJob = nil
            return
        }

        latestJob = jobs[0]

        let successCount = jobs.filter { $0.status == .succeed }.count
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
