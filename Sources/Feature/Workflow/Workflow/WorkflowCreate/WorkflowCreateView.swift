//
//  WorkflowCreateView.swift
//  Workflow
//
//  Created by Hypo on 2025/1/17.
//

import SwiftUI
import Domain
import Styleguide

public struct WorkflowCreateView: View {
    @State private var viewModel: WorkflowCreateViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WorkflowCreateViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView

            Form {
                basicInfoSection
                nodesSection
            }
            .formStyle(.grouped)

            Divider()

            footerView
        }
        .frame(minWidth: 700, minHeight: 600)
        .task { await viewModel.loadPlugins() }
        .onChange(of: viewModel.dismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Create Workflow")
                .font(.headline)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)

            Toggle("Enable", isOn: $viewModel.enable)
        }
    }

    private var nodesSection: some View {
        Section("Nodes (\(viewModel.nodes.count))") {
            if viewModel.nodes.isEmpty {
                Text("No nodes added. Click 'Add Node' to start building your workflow.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array($viewModel.nodes.enumerated()), id: \.element.id) { index, $node in
                    NodeCardView(
                        nodeIndex: index,
                        node: $node,
                        isExpanded: viewModel.isNodeExpanded(node.id),
                        onToggleExpanded: {
                            viewModel.toggleNodeExpanded(node.id)
                        },
                        onRemove: {
                            viewModel.removeNode(at: IndexSet(integer: index))
                        },
                        availableNodeNames: viewModel.availableNodeNames,
                        availableNodeTypes: viewModel.allNodeTypes
                    )
                }
                .onDelete { offsets in
                    viewModel.removeNode(at: offsets)
                }
            }

            Button {
                viewModel.addNode()
            } label: {
                Label("Add Node", systemImage: "plus.circle")
            }
        }
    }

    private var footerView: some View {
        HStack {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            .keyboardShortcut(.escape)

            Button {
                Task {
                    await viewModel.createWorkflow()
                }
            } label: {
                if viewModel.isCreating {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("Create")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isCreating)
            .keyboardShortcut(.return, modifiers: [.command])
        }
        .padding()
    }
}

#Preview {
    WorkflowCreateView(
        viewModel: WorkflowCreateViewModel(
            usecase: MockWorkflowUseCase(),
            onCreated: nil
        )
    )
}

// MARK: - Mock UseCase for Preview

private class MockWorkflowUseCase: WorkflowUseCaseProtocol {
    func listWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [any Domain.Workflow] {
        []
    }

    func getWorkflow(id: String) async throws -> Domain.Workflow {
        fatalError()
    }

    func createWorkflow(option: Domain.WorkflowCreationOption) async throws -> Domain.Workflow {
        fatalError()
    }

    func listWorkflowJobs(workflow: String, status: [Domain.WorkflowJobStatus]?, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [any Domain.WorkflowJob] {
        []
    }

    func triggerWorkflow(_ workflow: String, option: Domain.WorkflowJobOption) async throws -> Domain.WorkflowJob {
        fatalError()
    }

    func pauseWorkflowJob(workflowId: String, jobId: String) async throws {
        fatalError()
    }

    func resumeWorkflowJob(workflowId: String, jobId: String) async throws {
        fatalError()
    }

    func cancelWorkflowJob(workflowId: String, jobId: String) async throws {
        fatalError()
    }

    func listWorkflowPlugins() async throws -> [any Domain.WorkflowPlugin] {
        []
    }
}
