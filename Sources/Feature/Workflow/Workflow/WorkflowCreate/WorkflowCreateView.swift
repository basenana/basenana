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
                triggerSection
                nodesSection
            }
            .formStyle(.grouped)

            Divider()

            footerView
        }
        .frame(minWidth: 650, minHeight: 550)
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

            TextField("Queue Name (optional)", text: $viewModel.queueName)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var triggerSection: some View {
        Section("Trigger") {
            Picker("Type", selection: $viewModel.triggerType) {
                ForEach(WorkflowCreateViewModel.TriggerType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)

            triggerConfigFields
        }
    }

    @ViewBuilder
    private var triggerConfigFields: some View {
        switch viewModel.triggerType {
        case .rss:
            VStack(alignment: .leading, spacing: 8) {
                TextField("Feed URL", text: $viewModel.rssFeed)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Text("Interval (seconds)")
                    Spacer()
                    TextField("3600", value: $viewModel.rssInterval, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
            }

        case .interval:
            HStack {
                Text("Interval (seconds)")
                Spacer()
                TextField("300", value: $viewModel.intervalSeconds, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
            }

        case .localFileWatch:
            VStack(alignment: .leading, spacing: 8) {
                TextField("Directory", text: $viewModel.fileWatchDirectory)
                    .textFieldStyle(.roundedBorder)

                Picker("Event", selection: $viewModel.fileWatchEvent) {
                    ForEach(WorkflowCreateViewModel.FileWatchEvent.allCases, id: \.self) { event in
                        Text(event.rawValue).tag(event)
                    }
                }

                TextField("File Pattern (optional)", text: $viewModel.fileWatchPattern)
                    .textFieldStyle(.roundedBorder)

                TextField("File Types (optional, e.g., .pdf,.doc)", text: $viewModel.fileWatchFileTypes)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Text("Min Size (bytes)")
                    Spacer()
                    TextField("optional", value: $viewModel.fileWatchMinSize, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                }

                HStack {
                    Text("Max Size (bytes)")
                    Spacer()
                    TextField("optional", value: $viewModel.fileWatchMaxSize, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                }

                TextField("CEL Pattern (optional)", text: $viewModel.fileWatchCelPattern)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var nodesSection: some View {
        Section("Nodes (\(viewModel.nodes.count))") {
            if viewModel.nodes.isEmpty {
                Text("No nodes added")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach($viewModel.nodes) { $node in
                    nodeRow(node: $node)
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

    @ViewBuilder
    private func nodeRow(node: Binding<WorkflowCreateViewModel.NodeFormData>) -> some View {
        HStack(spacing: 12) {
            TextField("Name", text: node.name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)

            TextField("Type", text: node.type)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)

            TextField("Next (optional)", text: node.next)
                .textFieldStyle(.roundedBorder)
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
}
