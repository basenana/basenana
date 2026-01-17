//
//  WorkflowCreateViewModel.swift
//  Workflow
//
//  Created by Hypo on 2025/1/17.
//

import SwiftUI
import Domain
import Data

@Observable
@MainActor
public class WorkflowCreateViewModel {
    // Basic info
    var name: String = ""
    var enable: Bool = true
    var queueName: String = ""

    // Trigger config
    var triggerType: TriggerType = .rss
    var rssFeed: String = ""
    var rssInterval: Int = 3600
    var intervalSeconds: Int = 300
    var fileWatchDirectory: String = ""
    var fileWatchEvent: FileWatchEvent = .create
    var fileWatchPattern: String = ""
    var fileWatchFileTypes: String = ""
    var fileWatchMinSize: Int?
    var fileWatchMaxSize: Int?
    var fileWatchCelPattern: String = ""

    // Nodes
    var nodes: [NodeFormData] = []

    // Status
    var isCreating: Bool = false
    var errorMessage: String?
    var dismiss: Bool = false

    enum TriggerType: String, CaseIterable {
        case rss = "RSS"
        case interval = "Interval"
        case localFileWatch = "File Watch"
    }

    enum FileWatchEvent: String, CaseIterable {
        case create = "create"
        case modify = "modify"
        case delete = "delete"
    }

    struct NodeFormData: Identifiable {
        var id: UUID = UUID()
        var name: String = ""
        var type: String = ""
        var next: String = ""
    }

    private let usecase: any WorkflowUseCaseProtocol
    private let onCreated: ((Workflow) -> Void)?

    init(usecase: any WorkflowUseCaseProtocol, onCreated: ((Workflow) -> Void)? = nil) {
        self.usecase = usecase
        self.onCreated = onCreated
    }

    func addNode() {
        nodes.append(.init())
    }

    func removeNode(at offsets: IndexSet) {
        nodes.remove(atOffsets: offsets)
    }

    func createWorkflow() async {
        guard !name.isEmpty else {
            errorMessage = "Name is required"
            return
        }

        guard !nodes.isEmpty else {
            errorMessage = "At least one node is required"
            return
        }

        isCreating = true
        errorMessage = nil

        do {
            let trigger = buildTrigger()
            let workflowNodes = nodes.map { nodeData -> APIWorkflowNode in
                APIWorkflowNode(
                    name: nodeData.name,
                    type: nodeData.type,
                    params: nil,
                    input: nil,
                    next: nodeData.next.isEmpty ? nil : nodeData.next,
                    condition: nil,
                    branches: nil,
                    cases: nil,
                    defaultCase: nil,
                    matrix: nil
                )
            }

            let option = WorkflowCreationOption(
                name: name,
                trigger: trigger,
                nodes: workflowNodes,
                enable: enable,
                queueName: queueName.isEmpty ? nil : queueName
            )

            let workflow = try await usecase.createWorkflow(option: option)
            onCreated?(workflow)
            dismiss = true
        } catch {
            errorMessage = "Create workflow failed: \(error.localizedDescription)"
        }

        isCreating = false
    }

    private func buildTrigger() -> WorkflowTrigger {
        switch triggerType {
        case .rss:
            let rss = APIWorkflowTriggerRSS(feed: rssFeed, interval: rssInterval)
            return .rss(rss)

        case .interval:
            let interval = APIWorkflowTriggerInterval(interval: intervalSeconds)
            return .interval(interval)

        case .localFileWatch:
            let fileWatch = APIWorkflowTriggerLocalFileWatch(
                directory: fileWatchDirectory,
                event: fileWatchEvent.rawValue,
                filePattern: fileWatchPattern.isEmpty ? nil : fileWatchPattern,
                fileTypes: fileWatchFileTypes.isEmpty ? nil : fileWatchFileTypes,
                minFileSize: fileWatchMinSize,
                maxFileSize: fileWatchMaxSize,
                celPattern: fileWatchCelPattern.isEmpty ? nil : fileWatchCelPattern
            )
            return .localFileWatch(fileWatch)
        }
    }
}
