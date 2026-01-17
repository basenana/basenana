//
//  WorkflowCreateView.swift
//  Feature
//
//  Created by Hypo on 2025/1/17.
//

import SwiftUI
import Domain
import Styleguide

public struct WorkflowCreateView: View {
    @State private var viewModel: WorkflowCreateViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private let onCreated: (() -> Void)?

    public init(viewModel: WorkflowCreateViewModel, onCreated: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onCreated = onCreated
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(spacing: 0) {
                    basicInfoSection
                        .padding(.vertical, 20)
                        .padding(.top, 16)

                    Divider()
                        .padding(.vertical, 16)

                    inputParametersSection
                        .padding(.vertical, 20)

                    Divider()
                        .padding(.vertical, 16)

                    nodesSection
                        .padding(.vertical, 20)
                        .padding(.bottom, 80)
                }
            }

            Divider()

            footerView
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(colorScheme == .dark ? Color(white: 0.12) : Color(white: 0.95))
        }
        .frame(minWidth: 800, minHeight: 700)
        .navigationTitle("Create Workflow")
        .task { await viewModel.loadPlugins() }
        .onChange(of: viewModel.dismiss) { _, newValue in
            if newValue {
                onCreated?()
                dismiss.callAsFunction()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color.white)
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Info")
                .font(.headline)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Workflow Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 300)
                }

                Toggle("Enable", isOn: $viewModel.enable)
                    .padding(.top, 22)
            }
        }
    }

    private var inputParametersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trigger Input Parameters")
                    .font(.headline)

                Text("(\(viewModel.inputParameters.count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if viewModel.inputParameters.isEmpty {
                Text("No input parameters defined. Add parameters to allow users to provide input when triggering the workflow.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach($viewModel.inputParameters) { $param in
                        inputParamRow(for: $param)
                    }
                }
            }

            Button {
                viewModel.addInputParameter()
            } label: {
                Label("Add Parameter", systemImage: "plus.circle")
                    .font(.subheadline)
            }
            .padding(.top, 4)
        }
    }

    private func inputParamRow(for param: Binding<WorkflowCreateViewModel.InputParamFormData>) -> some View {
        HStack(spacing: 12) {
            TextField("Name", text: param.name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)

            TextField("Description", text: param.describe)
                .textFieldStyle(.roundedBorder)

            Toggle("Required", isOn: param.required)
                .labelsHidden()
                .frame(width: 60)

            Button {
                if let index = viewModel.inputParameters.firstIndex(where: { $0.id == param.id.wrappedValue }) {
                    viewModel.removeInputParameter(at: IndexSet(integer: index))
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }

    private var nodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nodes")
                    .font(.headline)

                Text("(\(viewModel.nodes.count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if viewModel.nodes.isEmpty {
                VStack(spacing: 8) {
                    Text("No nodes added")
                        .foregroundColor(.secondary)

                    Button {
                        viewModel.addNode()
                    } label: {
                        Label("Add Node", systemImage: "plus.circle")
                            .font(.subheadline)
                    }
                }
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array($viewModel.nodes.enumerated()), id: \.element.id) { index, $node in
                        WorkflowCreateNodeCard(
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
                }

                Button {
                    viewModel.addNode()
                } label: {
                    Label("Add Node", systemImage: "plus.circle")
                        .font(.subheadline)
                        .padding(.top, 8)
                }
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
        }
    }
}

#Preview {
    NavigationStack {
        WorkflowCreateView(
            viewModel: WorkflowCreateViewModel(
                usecase: MockWorkflowUseCase(),
                onCreated: nil
            )
        )
    }
}

// MARK: - Mock UseCase for Preview

private class MockWorkflowUseCase: WorkflowUseCaseProtocol {
    func listWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [Workflow] { [] }
    func getWorkflow(id: String) async throws -> Workflow { fatalError() }
    func createWorkflow(option: WorkflowCreationOption) async throws -> Workflow { fatalError() }
    func listWorkflowJobs(workflow: String, status: [WorkflowJobStatus]?, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [WorkflowJob] { [] }
    func triggerWorkflow(_ workflow: String, option: WorkflowJobOption) async throws -> WorkflowJob { fatalError() }
    func pauseWorkflowJob(workflowId: String, jobId: String) async throws {}
    func resumeWorkflowJob(workflowId: String, jobId: String) async throws {}
    func cancelWorkflowJob(workflowId: String, jobId: String) async throws {}
    func listWorkflowPlugins() async throws -> [WorkflowPlugin] { [] }
}
