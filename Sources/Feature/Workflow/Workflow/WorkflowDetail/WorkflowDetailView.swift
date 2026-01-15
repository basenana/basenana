//
//  WorkflowDetailView.swift
//  Workflow
//
//  Created by Hypo on 2024/12/7.
//

import SwiftUI
import Foundation
import Domain
import Styleguide


public struct WorkflowDetailView: View {

    @State private var viewModel: WorkflowDetailViewModel

    public init(viewModel: WorkflowDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                loadingView
            } else if let workflow = viewModel.workflow {
                workflowDetailSection(workflow: workflow)

                Divider()
                    .padding(.horizontal, 16)

                jobListSection
            } else {
                emptyView
            }
        }
        .task { await viewModel.initWorkflow() }
        .frame(minWidth: 900, minHeight: 700)
        .navigationTitle(viewModel.workflow?.name ?? "Workflow")
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading workflow...")
                .font(.subheadline)
                .foregroundColor(.WorkflowTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Workflow not found")
                .font(.subheadline)
                .foregroundColor(.WorkflowTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func workflowDetailSection(workflow: WorkflowItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(workflow.name)
                            .font(.title2.bold())
                            .foregroundColor(.CardFrontground)

                        Circle()
                            .fill(workflow.enable ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                    }

                    Text("\(workflow.namespace)")
                        .font(.caption)
                        .foregroundColor(.WorkflowTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Queue: \(workflow.queueName)")
                        .font(.caption)
                        .foregroundColor(.WorkflowTextSecondary)

                    Text("Last triggered: \(relativeTimeString(from: workflow.lastTriggeredAt))")
                        .font(.caption2)
                        .foregroundColor(.WorkflowTextSecondary)
                }
            }

            if let trigger = workflow.trigger {
                triggerInfoView(trigger: trigger)
            }

            if !workflow.nodes.isEmpty {
                nodesSection(nodes: workflow.nodes)
            }
        }
        .padding(16)
        .background(Color.background)
    }

    @ViewBuilder
    private func triggerInfoView(trigger: WorkflowTrigger) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Trigger")
                .font(.caption.bold())
                .foregroundColor(.WorkflowTextSecondary)

            switch trigger {
            case .rss(let rss):
                HStack(spacing: 16) {
                    Label("RSS", systemImage: "rss")
                        .font(.caption)
                        .foregroundColor(.WorkflowPending)
                    Text(rss.feed)
                        .font(.caption)
                        .foregroundColor(.CardFrontground)
                        .lineLimit(1)
                }

            case .interval(let interval):
                HStack(spacing: 16) {
                    Label("Interval", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.WorkflowPending)
                    Text("\(interval) seconds")
                        .font(.caption)
                        .foregroundColor(.CardFrontground)
                }

            case .localFileWatch(let watch):
                HStack(spacing: 16) {
                    Label("File Watch", systemImage: "eye")
                        .font(.caption)
                        .foregroundColor(.WorkflowPending)
                    Text(watch.path)
                        .font(.caption)
                        .foregroundColor(.CardFrontground)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(Color.secondaryBackground)
        .cornerRadius(8)
    }

    @ViewBuilder
    private func nodesSection(nodes: [any WorkflowNode]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nodes (\(nodes.count))")
                .font(.caption.bold())
                .foregroundColor(.WorkflowTextSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(nodes.indices, id: \.self) { index in
                        let node = nodes[index]
                        nodeCard(node: node, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func nodeCard(node: any WorkflowNode, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(node.name)
                    .font(.caption.bold())
                    .foregroundColor(.CardFrontground)

                Spacer()

                Text(node.type)
                    .font(.caption2)
                    .foregroundColor(.WorkflowPending)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondaryBackground)
                    .cornerRadius(4)
            }

            if let params = node.params, !params.isEmpty {
                Text(params.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
                    .lineLimit(2)
            }

            if let next = node.next {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text("Next: \(next)")
                        .font(.caption2)
                }
                .foregroundColor(.WorkflowTextSecondary)
            }
        }
        .padding(10)
        .frame(width: 180)
        .background(Color.secondaryBackground)
        .cornerRadius(8)
    }

    @ViewBuilder
    private var jobListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Jobs")
                    .font(.headline)
                    .foregroundColor(.CardFrontground)

                Spacer()

                Text("\(viewModel.jobs.count) jobs")
                    .font(.caption)
                    .foregroundColor(.WorkflowTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.jobs) { job in
                        JobRow(job: job, viewModel: viewModel)
                            .onAppear {
                                if job.id == viewModel.jobs.last?.id {
                                    Task { await viewModel.loadJobs(reset: false) }
                                }
                            }
                    }

                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(maxHeight: .infinity)
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
