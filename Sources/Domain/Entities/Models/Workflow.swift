//
//  Job.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation


public protocol Workflow {
    var id: String { get }
    var name: String { get }
    var enable: Bool { get }
    var namespace: String { get }
    var queueName: String { get }
    var trigger: WorkflowTrigger? { get }
    var nodes: [WorkflowNode] { get }

    var createdAt: Date { get }
    var updatedAt: Date { get }
    var lastTriggeredAt: Date { get }
}

public protocol WorkflowTriggerRSS {
    var feed: String { get }
    var interval: Int { get }
}

public protocol WorkflowTriggerInterval {
    var interval: Int { get }
}

public protocol WorkflowTriggerLocalFileWatch {
    var path: String { get }
}

public enum WorkflowTrigger {
    case rss(any WorkflowTriggerRSS)
    case interval(any WorkflowTriggerInterval)
    case localFileWatch(any WorkflowTriggerLocalFileWatch)
}

public protocol WorkflowNodeParam {
    var key: String { get }
    var value: String { get }
}

public protocol WorkflowNodeInput {
    var source: String { get }
}

public protocol WorkflowNodeMatrix {
    var data: [String: String] { get }
}

public struct WorkflowNodeParamStruct: WorkflowNodeParam {
    public var key: String
    public var value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct WorkflowNodeInputStruct: WorkflowNodeInput {
    public var source: String

    public init(source: String) {
        self.source = source
    }
}

public struct WorkflowNodeMatrixStruct: WorkflowNodeMatrix {
    public var data: [String: String]

    public init(data: [String: String]) {
        self.data = data
    }
}

public protocol WorkflowNode {
    var name: String { get }
    var type: String { get }
    var params: [any WorkflowNodeParam]? { get }
    var input: (any WorkflowNodeInput)? { get }
    var next: String? { get }
    var matrix: (any WorkflowNodeMatrix)? { get }
}

public struct WorkflowJobTarget {
    public var entries: [String]
    public var parentEntryID: String

    public init(entries: [String], parentEntryID: String) {
        self.entries = entries
        self.parentEntryID = parentEntryID
    }
}

public protocol WorkflowJobStep {
    var name: String { get }
    var status: String { get }
    var message: String { get }
}

public struct WorkflowJobOption {
    public var uri: String?
    public var reason: String?
    public var timeout: Int64?

    public init(uri: String? = nil, reason: String? = nil, timeout: Int64? = nil) {
        self.uri = uri
        self.reason = reason
        self.timeout = timeout
    }
}

public protocol WorkflowJob {
    var id: String { get }
    var workflow: String { get }
    var triggerReason: String { get }
    var status: String { get }
    var message: String { get }
    var queueName: String { get }

    var jobTarget: WorkflowJobTarget { get }
    var steps: [any WorkflowJobStep] { get }

    var createdAt: Date { get }
    var updatedAt: Date { get }
    var startAt: Date { get }
    var finishAt: Date { get }
}
