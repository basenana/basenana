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
    // MARK: - Basic Info
    var name: String = ""
    var enable: Bool = true

    // MARK: - Input Parameters
    var inputParameters: [InputParamFormData] = []

    // MARK: - Nodes
    var nodes: [NodeFormData] = []
    var expandedNodeIds: Set<UUID> = []

    // MARK: - Plugins
    var availablePlugins: [WorkflowPlugin] = []
    var isLoadingPlugins: Bool = false

    // MARK: - Status
    var isCreating: Bool = false
    var errorMessage: String?
    var dismiss: Bool = false

    // MARK: - Types (using NodeDefinition)
    typealias KeyValueItem = NodeDefinition.KeyValueItem
    typealias BranchItem = NodeDefinition.BranchItem
    typealias CaseItem = NodeDefinition.CaseItem

    struct NodeFormData: Identifiable {
        var id: UUID = UUID()
        var name: String = ""
        var type: String = ""  // Logic node types: "condition", "switch"; Plugin types: plugin.name
        var isLogicNode: Bool = false  // true for condition/switch, false for plugins
        var next: String = ""
        var params: [KeyValueItem] = []  // For logic nodes (http, transform, etc.)
        var pluginParams: [String: String] = [:]  // For plugin nodes

        // Matrix (for plugin nodes to support iteration over arrays)
        var matrix: [KeyValueItem] = []

        // Control flow (only for condition/switch)
        var condition: String = ""
        var branches: [BranchItem] = []
        var cases: [CaseItem] = []
        var defaultNext: String = ""

        /// Definition for logic nodes
        var logicDefinition: NodeTypeDefinition? {
            guard isLogicNode, let nodeType = NodeDefinition.NodeType(rawValue: type) else {
                return nil
            }
            return NodeDefinition.definition(for: nodeType)
        }

        /// Plugin definition (for plugin nodes)
        var pluginDefinition: WorkflowPlugin? {
            nil
        }
    }

    struct InputParamFormData: Identifiable {
        var id: UUID = UUID()
        var name: String = ""
        var describe: String = ""
        var required: Bool = true
    }

    // MARK: - Private
    private let usecase: any WorkflowUseCaseProtocol
    private let onCreated: ((Workflow) -> Void)?

    public init(usecase: any WorkflowUseCaseProtocol, onCreated: ((Workflow) -> Void)? = nil) {
        self.usecase = usecase
        self.onCreated = onCreated
    }

    // MARK: - Plugin Loading

    func loadPlugins() async {
        isLoadingPlugins = true
        do {
            availablePlugins = try await usecase.listWorkflowPlugins()
        } catch {
            availablePlugins = []
        }
        isLoadingPlugins = false
    }

    // MARK: - Available Node Types

    /// Logic node types (built-in)
    var logicNodeTypes: [NodeTypeInfo] {
        [
            NodeTypeInfo(type: "condition", displayName: "Condition", description: "Branch based on CEL condition", icon: "arrow.triangle.branch", color: "orange"),
            NodeTypeInfo(type: "switch", displayName: "Switch", description: "Branch based on value matching", icon: "point.topright.arrow.to.point.bottomleft.squareroot", color: "purple")
        ]
    }

    /// All available node types (logic + plugins)
    var allNodeTypes: [NodeTypeInfo] {
        var types = logicNodeTypes
        for plugin in availablePlugins {
            types.append(NodeTypeInfo(
                type: plugin.name,
                displayName: plugin.name.capitalized,
                description: "\(plugin.type) plugin v\(plugin.version)",
                icon: "cube.box",
                color: "blue",
                isPlugin: true,
                plugin: plugin
            ))
        }
        return types
    }

    struct NodeTypeInfo: Identifiable, Equatable {
        var id: String { type }
        let type: String
        let displayName: String
        let description: String
        let icon: String
        let color: String
        var isPlugin: Bool = false
        var plugin: WorkflowPlugin?

        static func == (lhs: NodeTypeInfo, rhs: NodeTypeInfo) -> Bool {
            lhs.id == rhs.id
        }
    }

    // MARK: - Node Operations

    func addNode() {
        let node = NodeFormData()
        nodes.append(node)
        expandedNodeIds.insert(node.id)
    }

    func removeNode(at offsets: IndexSet) {
        let idsToRemove = offsets.map { nodes[$0].id }
        nodes.remove(atOffsets: offsets)
        expandedNodeIds.subtract(idsToRemove)
    }

    func toggleNodeExpanded(_ nodeId: UUID) {
        if expandedNodeIds.contains(nodeId) {
            expandedNodeIds.remove(nodeId)
        } else {
            expandedNodeIds.insert(nodeId)
        }
    }

    func isNodeExpanded(_ nodeId: UUID) -> Bool {
        expandedNodeIds.contains(nodeId)
    }

    // MARK: - Key-Value Operations

    func addParam(to nodeIndex: Int) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].params.append(KeyValueItem())
    }

    func removeParam(from nodeIndex: Int, at offsets: IndexSet) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].params.remove(atOffsets: offsets)
    }

    func addBranch(to nodeIndex: Int) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].branches.append(BranchItem())
    }

    func removeBranch(from nodeIndex: Int, at offsets: IndexSet) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].branches.remove(atOffsets: offsets)
    }

    func addCase(to nodeIndex: Int) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].cases.append(CaseItem())
    }

    func removeCase(from nodeIndex: Int, at offsets: IndexSet) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].cases.remove(atOffsets: offsets)
    }

    func addMatrixItem(to nodeIndex: Int) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].matrix.append(KeyValueItem())
    }

    func removeMatrixItem(from nodeIndex: Int, at offsets: IndexSet) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].matrix.remove(atOffsets: offsets)
    }

    // MARK: - Input Parameter Operations

    func addInputParameter() {
        inputParameters.append(InputParamFormData())
    }

    func removeInputParameter(at offsets: IndexSet) {
        inputParameters.remove(atOffsets: offsets)
    }

    // MARK: - Plugin Param Operations

    func updatePluginParam(for nodeIndex: Int, key: String, value: String) {
        guard nodes.indices.contains(nodeIndex) else { return }
        nodes[nodeIndex].pluginParams[key] = value
    }

    // MARK: - Available Node Names

    var availableNodeNames: [String] {
        nodes.map { $0.name }.filter { !$0.isEmpty }
    }

    // MARK: - Create Workflow

    func createWorkflow() async {
        guard !name.isEmpty else {
            errorMessage = "Name is required"
            return
        }

        guard !nodes.isEmpty else {
            errorMessage = "At least one node is required"
            return
        }

        for (index, node) in nodes.enumerated() {
            if node.name.isEmpty {
                errorMessage = "Node \(index + 1): Name is required"
                return
            }
        }

        isCreating = true
        errorMessage = nil

        do {
            let trigger = buildDefaultTrigger()
            let workflowNodes = nodes.enumerated().map { index, nodeData -> APIWorkflowNode in
                var params: [APIWorkflowNodeParam] = []

                if nodeData.isLogicNode {
                    // Logic node: use params array
                    params = nodeData.params.compactMap { item -> APIWorkflowNodeParam? in
                        guard !item.key.isEmpty else { return nil }
                        return APIWorkflowNodeParam(key: item.key, value: item.value)
                    }
                } else {
                    // Plugin node: use pluginParams dictionary
                    params = nodeData.pluginParams.compactMap { key, value -> APIWorkflowNodeParam? in
                        guard !key.isEmpty else { return nil }
                        return APIWorkflowNodeParam(key: key, value: value)
                    }
                }

                let nodeType = nodeData.type
                let isCondition = nodeType == "condition"
                let isSwitch = nodeType == "switch"

                // Matrix is supported for all plugin nodes (non-logic nodes)
                let matrixData = nodeData.isLogicNode ? nil : dictFromKeyValues(nodeData.matrix)
                let hasMatrix = !(matrixData?.isEmpty ?? true)

                return APIWorkflowNode(
                    name: nodeData.name,
                    type: nodeType,
                    params: params.isEmpty ? nil : params,
                    input: nil,
                    next: nodeData.next.isEmpty ? nil : nodeData.next,
                    condition: isCondition ? nodeData.condition : nil,
                    branches: isCondition ? dictFromBranches(nodeData.branches) : nil,
                    cases: isSwitch ? nodeData.cases.map {
                        APIWorkflowNodeCase(value: $0.value, next: $0.nodeName)
                    } : nil,
                    defaultCase: isSwitch ? nodeData.defaultNext : nil,
                    matrix: hasMatrix ? APIWorkflowNodeMatrix(data: matrixData!) : nil
                )
            }

            let inputParams = inputParameters.compactMap { param -> WorkflowInputParameter? in
                guard !param.name.isEmpty else { return nil }
                return WorkflowInputParameterStruct(
                    name: param.name,
                    describe: param.describe,
                    required: param.required
                )
            }

            let option = WorkflowCreationOption(
                name: name,
                trigger: trigger,
                nodes: workflowNodes,
                enable: enable,
                inputParameters: inputParams.isEmpty ? nil : inputParams
            )

            let workflow = try await usecase.createWorkflow(option: option)
            onCreated?(workflow)
            dismiss = true
        } catch {
            errorMessage = "Create workflow failed: \(error.localizedDescription)"
        }

        isCreating = false
    }

    // MARK: - Private Helpers

    private func buildDefaultTrigger() -> WorkflowTrigger {
        let rss = APIWorkflowTriggerRSS(feed: "", interval: 3600)
        return .rss(rss)
    }

    private func dictFromKeyValues(_ items: [KeyValueItem]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: items.compactMap { item in
            guard !item.key.isEmpty else { return nil }
            return (item.key, item.value)
        })
    }

    private func dictFromBranches(_ branches: [BranchItem]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: branches.compactMap { branch in
            guard !branch.branchName.isEmpty, !branch.nodeName.isEmpty else { return nil }
            return (branch.branchName, branch.nodeName)
        })
    }
}
