//
//  WorkflowCreateViewModelTests.swift
//  FeatureTests
//
//  Created by Hypo on 2025/1/17.
//

import XCTest
@testable import Feature
import Domain

final class WorkflowCreateViewModelTests: XCTestCase {

    // MARK: - NodeDefinition Tests

    func testNodeTypeCases() {
        let types = NodeDefinition.NodeType.allCases
        XCTAssertEqual(types.count, 6)
        XCTAssertTrue(types.contains(.http))
        XCTAssertTrue(types.contains(.condition))
        XCTAssertTrue(types.contains(.switchType))
        XCTAssertTrue(types.contains(.loop))
        XCTAssertTrue(types.contains(.transform))
        XCTAssertTrue(types.contains(.output))
    }

    func testNodeTypeRawValues() {
        XCTAssertEqual(NodeDefinition.NodeType.http.rawValue, "http")
        XCTAssertEqual(NodeDefinition.NodeType.condition.rawValue, "condition")
        XCTAssertEqual(NodeDefinition.NodeType.switchType.rawValue, "switch")
        XCTAssertEqual(NodeDefinition.NodeType.loop.rawValue, "loop")
        XCTAssertEqual(NodeDefinition.NodeType.transform.rawValue, "transform")
        XCTAssertEqual(NodeDefinition.NodeType.output.rawValue, "output")
    }

    func testNodeTypeDisplayNames() {
        XCTAssertEqual(NodeDefinition.NodeType.http.displayName, "HTTP Request")
        XCTAssertEqual(NodeDefinition.NodeType.condition.displayName, "Condition")
        XCTAssertEqual(NodeDefinition.NodeType.switchType.displayName, "Switch")
        XCTAssertEqual(NodeDefinition.NodeType.loop.displayName, "Loop")
        XCTAssertEqual(NodeDefinition.NodeType.transform.displayName, "Transform")
        XCTAssertEqual(NodeDefinition.NodeType.output.displayName, "Output")
    }

    func testNodeTypeSupportsNext() {
        XCTAssertTrue(NodeDefinition.NodeType.http.supportsNext)
        XCTAssertTrue(NodeDefinition.NodeType.condition.supportsNext)
        XCTAssertTrue(NodeDefinition.NodeType.switchType.supportsNext)
        XCTAssertTrue(NodeDefinition.NodeType.loop.supportsNext)
        XCTAssertTrue(NodeDefinition.NodeType.transform.supportsNext)
        XCTAssertFalse(NodeDefinition.NodeType.output.supportsNext)
    }

    func testNodeTypeHasControlFlow() {
        XCTAssertFalse(NodeDefinition.NodeType.http.hasControlFlow)
        XCTAssertTrue(NodeDefinition.NodeType.condition.hasControlFlow)
        XCTAssertTrue(NodeDefinition.NodeType.switchType.hasControlFlow)
        XCTAssertTrue(NodeDefinition.NodeType.loop.hasControlFlow)
        XCTAssertFalse(NodeDefinition.NodeType.transform.hasControlFlow)
        XCTAssertFalse(NodeDefinition.NodeType.output.hasControlFlow)
    }

    func testAllNodeTypesDefinition() {
        let allTypes = NodeDefinition.allNodeTypes
        XCTAssertEqual(allTypes.count, 6)

        for typeDef in allTypes {
            XCTAssertFalse(typeDef.displayName.isEmpty)
            XCTAssertFalse(typeDef.icon.isEmpty)
            XCTAssertFalse(typeDef.color.isEmpty)
        }
    }

    // MARK: - NodeFormData Tests

    func testNodeFormDataInitialization() {
        let node = WorkflowCreateViewModel.NodeFormData()
        XCTAssertEqual(node.name, "")
        XCTAssertEqual(node.type, "")
        XCTAssertFalse(node.isLogicNode)
        XCTAssertEqual(node.next, "")
        XCTAssertTrue(node.params.isEmpty)
    }

    func testNodeFormDataWithLogicNode() {
        let node = WorkflowCreateViewModel.NodeFormData(
            name: "test-node",
            type: "condition",
            isLogicNode: true,
            next: "next-node"
        )
        XCTAssertEqual(node.name, "test-node")
        XCTAssertEqual(node.type, "condition")
        XCTAssertTrue(node.isLogicNode)
        XCTAssertEqual(node.next, "next-node")
    }

    func testNodeFormDataWithPluginNode() {
        let node = WorkflowCreateViewModel.NodeFormData(
            name: "archive-node",
            type: "archive",
            isLogicNode: false,
            pluginParams: ["action": "compress"]
        )
        XCTAssertEqual(node.name, "archive-node")
        XCTAssertEqual(node.type, "archive")
        XCTAssertFalse(node.isLogicNode)
        XCTAssertEqual(node.pluginParams["action"], "compress")
    }

    func testNodeFormDataIdentifiable() {
        let node1 = WorkflowCreateViewModel.NodeFormData()
        let node2 = WorkflowCreateViewModel.NodeFormData()
        XCTAssertNotEqual(node1.id, node2.id)
    }

    // MARK: - NodeTypeInfo Tests

    func testNodeTypeInfoLogicNode() {
        let info = WorkflowCreateViewModel.NodeTypeInfo(
            type: "condition",
            displayName: "Condition",
            description: "Branch based on CEL",
            icon: "arrow.triangle.branch",
            color: "orange"
        )
        XCTAssertEqual(info.type, "condition")
        XCTAssertFalse(info.isPlugin)
        XCTAssertNil(info.plugin)
    }

    func testNodeTypeInfoWithPlugin() {
        let plugin = MockWorkflowPlugin()
        let info = WorkflowCreateViewModel.NodeTypeInfo(
            type: "archive",
            displayName: "Archive",
            description: "Archive plugin",
            icon: "archivebox",
            color: "blue",
            isPlugin: true,
            plugin: plugin
        )
        XCTAssertEqual(info.type, "archive")
        XCTAssertTrue(info.isPlugin)
        XCTAssertNotNil(info.plugin)
    }

    // MARK: - KeyValueItem Tests

    func testKeyValueItemInitialization() {
        let item = NodeDefinition.KeyValueItem()
        XCTAssertEqual(item.key, "")
        XCTAssertEqual(item.value, "")
    }

    func testKeyValueItemWithValues() {
        let item = NodeDefinition.KeyValueItem(key: "url", value: "https://example.com")
        XCTAssertEqual(item.key, "url")
        XCTAssertEqual(item.value, "https://example.com")
    }

    // MARK: - BranchItem Tests

    func testBranchItemInitialization() {
        let branch = NodeDefinition.BranchItem()
        XCTAssertEqual(branch.branchName, "")
        XCTAssertEqual(branch.nodeName, "")
    }

    func testBranchItemWithValues() {
        let branch = NodeDefinition.BranchItem(branchName: "success", nodeName: "parse")
        XCTAssertEqual(branch.branchName, "success")
        XCTAssertEqual(branch.nodeName, "parse")
    }

    // MARK: - CaseItem Tests

    func testCaseItemInitialization() {
        let caseItem = NodeDefinition.CaseItem()
        XCTAssertEqual(caseItem.value, "")
        XCTAssertEqual(caseItem.nodeName, "")
    }

    func testCaseItemWithValues() {
        let caseItem = NodeDefinition.CaseItem(value: "active", nodeName: "process")
        XCTAssertEqual(caseItem.value, "active")
        XCTAssertEqual(caseItem.nodeName, "process")
    }

    // MARK: - ParamDefinition Tests

    func testHttpNodeDefaultParams() {
        let definition = NodeDefinition.definition(for: .http)
        XCTAssertEqual(definition.params.count, 3)

        let urlParam = definition.params.first { $0.key == "url" }
        XCTAssertNotNil(urlParam)
        XCTAssertTrue(urlParam?.required ?? false)
        XCTAssertEqual(urlParam?.displayName, "URL")
    }

    func testConditionNodeDefaultParams() {
        let definition = NodeDefinition.definition(for: .condition)
        XCTAssertEqual(definition.params.count, 1)

        let exprParam = definition.params.first { $0.key == "expression" }
        XCTAssertNotNil(exprParam)
        XCTAssertTrue(exprParam?.required ?? false)
    }

    // MARK: - WorkflowPluginParameterStruct Tests

    func testWorkflowPluginParameterStructInitialization() {
        let param = WorkflowPluginParameterStruct(
            name: "action",
            required: false,
            defaultValue: "extract",
            description: "Action to perform",
            options: ["extract", "compress"]
        )
        XCTAssertEqual(param.name, "action")
        XCTAssertFalse(param.required)
        XCTAssertEqual(param.defaultValue, "extract")
        XCTAssertEqual(param.description, "Action to perform")
        XCTAssertEqual(param.options, ["extract", "compress"])
    }
}

// MARK: - Mock Classes

private class MockWorkflowPlugin: WorkflowPlugin {
    var name: String = "archive"
    var version: String = "1.0"
    var type: String = "process"
    var parameters: [WorkflowPluginParameter] = []
}
