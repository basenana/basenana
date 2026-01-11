//
//  WorkflowListView.swift
//  basenana
//
//  Created by Hypo on 2024/6/27.
//

import SwiftUI
import Domain
import Styleguide

public struct WorkflowListView: View {
    @State private var viewModel: WorkflowListViewModel
    @State private var searchText = ""
    @State private var selectedStatusFilter: HealthStatus?

    public init(viewModel: WorkflowListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            toolbarSection
            Divider()
            contentSection
        }
        .task { await viewModel.initWorkflows() }
        .frame(minWidth: 900, minHeight: 600)
        .navigationTitle("Workflow")
    }

    private var toolbarSection: some View {
        HStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.WorkflowTextSecondary)
                TextField("Search workflows...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color.secondaryBackground)
            .cornerRadius(8)
            .frame(maxWidth: 300)

            Picker("Status", selection: $selectedStatusFilter) {
                Text("All").tag(nil as HealthStatus?)
                Text("Healthy").tag(HealthStatus.healthy as HealthStatus?)
                Text("Warning").tag(HealthStatus.warning as HealthStatus?)
                Text("Critical").tag(HealthStatus.critical as HealthStatus?)
            }
            .pickerStyle(.menu)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            loadingView
        } else if filteredWorkflows.isEmpty {
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
                .foregroundColor(.WorkflowTextSecondary)

            Text("No workflows found")
                .font(.headline)
                .foregroundColor(.CardFrontground)

            Text(searchText.isEmpty ? "Create your first workflow to get started" : "Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.WorkflowTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var listView: some View {
        List {
            ForEach(filteredWorkflows) { workflow in
                WorkflowListRow(workflow: workflow)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        gotoDestination(.workflowDetail(workflow: workflow.id))
                    }
            }
        }
        .listStyle(.plain)
        .background(Color.background)
    }

    private var filteredWorkflows: [WorkflowItem] {
        var result = viewModel.workflows

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.executorDisplayName.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let status = selectedStatusFilter {
            result = result.filter { $0.healthStatus == status }
        }

        return result
    }
}

struct WorkflowListRow: View {
    let workflow: WorkflowItem
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(workflow.healthStatus.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.headline)
                    .foregroundColor(.CardFrontground)

                HStack(spacing: 4) {
                    Text(workflow.executorDisplayName)
                    Text("·")
                    Text(workflow.queueDisplayName)
                }
                .font(.caption)
                .foregroundColor(.WorkflowTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(workflow.healthScoreText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(workflow.healthStatus.color)

                Text("Updated \(workflow.updatedText)")
                    .font(.caption2)
                    .foregroundColor(.WorkflowTextSecondary)
            }
        }
        .padding(12)
        .background(isHovered ? Color.secondaryBackground : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
