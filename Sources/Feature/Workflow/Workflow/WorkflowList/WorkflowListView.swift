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

    public init(viewModel: WorkflowListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            contentSection
        }
        .task { await viewModel.initWorkflows() }
        .frame(minWidth: 900, minHeight: 600)
        .navigationTitle("Workflow")
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
        List {
            ForEach(viewModel.workflows) { workflow in
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
                    Text(workflow.queueDisplayName)
                }
                .font(.caption)
                .foregroundColor(.WorkflowTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
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
