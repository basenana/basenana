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
    var directory: String { get }
    var event: String { get }
    var filePattern: String? { get }
    var fileTypes: String? { get }
    var minFileSize: Int? { get }
    var maxFileSize: Int? { get }
    var celPattern: String? { get }
}

public struct WorkflowTriggerLocalFileWatchStruct: WorkflowTriggerLocalFileWatch {
    public var directory: String
    public var event: String
    public var filePattern: String?
    public var fileTypes: String?
    public var minFileSize: Int?
    public var maxFileSize: Int?
    public var celPattern: String?

    public init(directory: String, event: String, filePattern: String? = nil, fileTypes: String? = nil, minFileSize: Int? = nil, maxFileSize: Int? = nil, celPattern: String? = nil) {
        self.directory = directory
        self.event = event
        self.filePattern = filePattern
        self.fileTypes = fileTypes
        self.minFileSize = minFileSize
        self.maxFileSize = maxFileSize
        self.celPattern = celPattern
    }
}

public enum WorkflowTrigger {
    case rss(any WorkflowTriggerRSS)
    case interval(any WorkflowTriggerInterval)
    case localFileWatch(any WorkflowTriggerLocalFileWatch)
}

public protocol WorkflowInputParameter {
    var name: String { get }
    var describe: String { get }
    var required: Bool { get }
}

public struct WorkflowInputParameterStruct: WorkflowInputParameter {
    public var name: String
    public var describe: String
    public var required: Bool

    public init(name: String, describe: String, required: Bool) {
        self.name = name
        self.describe = describe
        self.required = required
    }
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
    var condition: String? { get }
    var branches: [String: String]? { get }
    var cases: [any WorkflowNodeCase]? { get }
    var defaultCase: String? { get }
    var matrix: (any WorkflowNodeMatrix)? { get }
}

public protocol WorkflowNodeCase {
    var value: String { get }
    var next: String { get }
}

public struct WorkflowNodeCaseStruct: WorkflowNodeCase {
    public var value: String
    public var next: String

    public init(value: String, next: String) {
        self.value = value
        self.next = next
    }
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
    public var parameters: [String: String]?

    public init(uri: String? = nil, reason: String? = nil, timeout: Int64? = nil, parameters: [String: String]? = nil) {
        self.uri = uri
        self.reason = reason
        self.timeout = timeout
        self.parameters = parameters
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

public struct WorkflowCreationOption {
    public var name: String
    public var trigger: WorkflowTrigger
    public var nodes: [any WorkflowNode]
    public var enable: Bool
    public var queueName: String?

    public init(name: String, trigger: WorkflowTrigger, nodes: [any WorkflowNode], enable: Bool = true, queueName: String? = nil) {
        self.name = name
        self.trigger = trigger
        self.nodes = nodes
        self.enable = enable
        self.queueName = queueName
    }
}
