//
//  WorkflowCreateViewModelTests.swift
//  FeatureTests
//
//  Created by Hypo on 2025/1/17.
//

import XCTest
@testable import Feature

final class WorkflowCreateViewModelTests: XCTestCase {

    func testNodeFormDataInitialization() {
        let node = WorkflowCreateViewModel.NodeFormData()
        XCTAssertEqual(node.name, "")
        XCTAssertEqual(node.type, "")
        XCTAssertEqual(node.next, "")
    }

    func testNodeFormDataWithValues() {
        let node = WorkflowCreateViewModel.NodeFormData(
            name: "test-node",
            type: "http",
            next: "next-node"
        )
        XCTAssertEqual(node.name, "test-node")
        XCTAssertEqual(node.type, "http")
        XCTAssertEqual(node.next, "next-node")
    }

    func testTriggerTypeCases() {
        let types = WorkflowCreateViewModel.TriggerType.allCases
        XCTAssertEqual(types.count, 3)
        XCTAssertTrue(types.contains(.rss))
        XCTAssertTrue(types.contains(.interval))
        XCTAssertTrue(types.contains(.localFileWatch))
    }

    func testTriggerTypeRawValues() {
        XCTAssertEqual(WorkflowCreateViewModel.TriggerType.rss.rawValue, "RSS")
        XCTAssertEqual(WorkflowCreateViewModel.TriggerType.interval.rawValue, "Interval")
        XCTAssertEqual(WorkflowCreateViewModel.TriggerType.localFileWatch.rawValue, "File Watch")
    }

    func testFileWatchEventCases() {
        let events = WorkflowCreateViewModel.FileWatchEvent.allCases
        XCTAssertEqual(events.count, 3)
        XCTAssertTrue(events.contains(.create))
        XCTAssertTrue(events.contains(.modify))
        XCTAssertTrue(events.contains(.delete))
    }

    func testFileWatchEventRawValues() {
        XCTAssertEqual(WorkflowCreateViewModel.FileWatchEvent.create.rawValue, "create")
        XCTAssertEqual(WorkflowCreateViewModel.FileWatchEvent.modify.rawValue, "modify")
        XCTAssertEqual(WorkflowCreateViewModel.FileWatchEvent.delete.rawValue, "delete")
    }

    func testNodeFormDataIdentifiable() {
        let node1 = WorkflowCreateViewModel.NodeFormData()
        let node2 = WorkflowCreateViewModel.NodeFormData()
        XCTAssertNotEqual(node1.id, node2.id)
    }

    func testNodeFormDataEquatable() {
        let node1 = WorkflowCreateViewModel.NodeFormData(name: "test", type: "http", next: "next")
        let node2 = WorkflowCreateViewModel.NodeFormData(name: "test", type: "http", next: "next")
        XCTAssertNotEqual(node1.id, node2.id)
    }
}
