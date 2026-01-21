//
//  JobModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import Foundation
import Domain


public struct APIWorkflowTriggerRSS: WorkflowTriggerRSS {
    public var feed: String
    public var interval: Int

    public init(feed: String, interval: Int) {
        self.feed = feed
        self.interval = interval
    }

    init(from dto: WorkflowTriggerRSSDTO?) {
        self.feed = dto?.feed ?? ""
        self.interval = dto?.interval ?? 0
    }
}

public struct APIWorkflowTriggerInterval: WorkflowTriggerInterval {
    public var interval: Int

    public init(interval: Int) {
        self.interval = interval
    }

    init(from interval: Int?) {
        self.interval = interval ?? 0
    }
}

public struct APIWorkflowTriggerLocalFileWatch: WorkflowTriggerLocalFileWatch {
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

    init(from dto: WorkflowTriggerLocalFileWatchDTO?) {
        self.directory = dto?.directory ?? ""
        self.event = dto?.event ?? ""
        self.filePattern = dto?.file_pattern
        self.fileTypes = dto?.file_types
        self.minFileSize = dto?.min_file_size
        self.maxFileSize = dto?.max_file_size
        self.celPattern = dto?.cel_pattern
    }
}

public struct APIWorkflowNodeParam: WorkflowNodeParam {
    public var key: String
    public var value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct APIWorkflowNodeInput: WorkflowNodeInput {
    public var source: String
    public var feed: String?
    public var file_path: String?
    public var site_name: String?
    public var site_url: String?
    public var title: String?
    public var url: String?
    public var document: String?
    public var parent_uri: String?
    public var otherFields: [String: String]?

    public init(source: String) {
        self.source = source
        self.feed = nil
        self.file_path = nil
        self.site_name = nil
        self.site_url = nil
        self.title = nil
        self.url = nil
        self.document = nil
        self.parent_uri = nil
        self.otherFields = nil
    }

    public init(dict: [String: String]) {
        self.source = dict["source"] ?? ""
        self.feed = dict["feed"]
        self.file_path = dict["file_path"]
        self.site_name = dict["site_name"]
        self.site_url = dict["site_url"]
        self.title = dict["title"]
        self.url = dict["url"]
        self.document = dict["document"]
        self.parent_uri = dict["parent_uri"]

        var otherFields = dict
        otherFields.removeValue(forKey: "source")
        otherFields.removeValue(forKey: "feed")
        otherFields.removeValue(forKey: "file_path")
        otherFields.removeValue(forKey: "site_name")
        otherFields.removeValue(forKey: "site_url")
        otherFields.removeValue(forKey: "title")
        otherFields.removeValue(forKey: "url")
        otherFields.removeValue(forKey: "document")
        otherFields.removeValue(forKey: "parent_uri")
        self.otherFields = otherFields.isEmpty ? nil : otherFields
    }

    init(from dto: WorkflowNodeInputDTO?) {
        self.source = dto?.source ?? dto?.feed ?? dto?.file_path ?? ""
        self.feed = dto?.feed
        self.file_path = dto?.file_path
        self.site_name = dto?.site_name
        self.site_url = dto?.site_url
        self.title = dto?.title
        self.url = dto?.url
        self.document = dto?.document
        self.parent_uri = dto?.parent_uri
        self.otherFields = nil
    }
}

public struct APIWorkflowNodeMatrix: WorkflowNodeMatrix {
    public var data: [String: Any]

    public init(data: [String: Any]) {
        self.data = data
    }

    init(from dto: WorkflowNodeMatrixDTO?) {
        self.data = dto?.data ?? [:]
    }
}

public struct APIWorkflowNodeCase: WorkflowNodeCase {
    public var value: String
    public var next: String

    public init(value: String, next: String) {
        self.value = value
        self.next = next
    }

    init(from dto: WorkflowNodeCaseDTO) {
        self.value = dto.value
        self.next = dto.next
    }
}

public struct APIWorkflowInputParameter: WorkflowInputParameter {
    public var name: String
    public var describe: String
    public var required: Bool

    public init(name: String, describe: String, required: Bool) {
        self.name = name
        self.describe = describe
        self.required = required
    }

    init(from dto: WorkflowInputParameterDTO) {
        self.name = dto.name
        self.describe = dto.describe
        self.required = dto.required
    }

    init(from param: WorkflowInputParameter) {
        self.name = param.name
        self.describe = param.describe
        self.required = param.required
    }
}

public struct APIWorkflowNode: WorkflowNode {
    public var name: String
    public var type: String
    public var params: [any WorkflowNodeParam]?
    public var input: (any WorkflowNodeInput)?
    public var next: String?
    public var condition: String?
    public var branches: [String: String]?
    public var cases: [any WorkflowNodeCase]?
    public var defaultCase: String?
    public var matrix: (any WorkflowNodeMatrix)?

    public init(name: String, type: String, params: [any WorkflowNodeParam]?, input: (any WorkflowNodeInput)?, next: String?, condition: String? = nil, branches: [String: String]? = nil, cases: [any WorkflowNodeCase]? = nil, defaultCase: String? = nil, matrix: (any WorkflowNodeMatrix)? = nil) {
        self.name = name
        self.type = type
        self.params = params
        self.input = input
        self.next = next
        self.condition = condition
        self.branches = branches
        self.cases = cases
        self.defaultCase = defaultCase
        self.matrix = matrix
    }

    init(from dto: WorkflowNodeDTO) {
        self.name = dto.name
        self.type = dto.type
        self.params = dto.params?.flatMap { key, value in
            [APIWorkflowNodeParam(key: key, value: value) as any WorkflowNodeParam]
        }
        self.input = dto.input.map { APIWorkflowNodeInput(from: $0) }
        self.next = dto.next
        self.condition = dto.condition
        self.branches = dto.branches
        self.cases = dto.cases?.map { APIWorkflowNodeCase(from: $0) }
        self.defaultCase = dto.default
        self.matrix = dto.matrix.map { APIWorkflowNodeMatrix(from: $0) }
    }
}

public struct APIWorkflow: Workflow {
    public var id: String
    public var name: String
    public var enable: Bool
    public var namespace: String
    public var queueName: String
    public var trigger: WorkflowTrigger?
    public var nodes: [any WorkflowNode]

    public var createdAt: Date
    public var updatedAt: Date
    public var lastTriggeredAt: Date

    public init(id: String, name: String, enable: Bool, namespace: String, queueName: String, trigger: WorkflowTrigger?, nodes: [any WorkflowNode], createdAt: Date, updatedAt: Date, lastTriggeredAt: Date) {
        self.id = id
        self.name = name
        self.enable = enable
        self.namespace = namespace
        self.queueName = queueName
        self.trigger = trigger
        self.nodes = nodes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastTriggeredAt = lastTriggeredAt
    }

    init(from dto: WorkflowDTO) {
        self.id = dto.id
        self.name = dto.name
        self.enable = dto.enable ?? true
        self.namespace = dto.namespace ?? ""
        self.queueName = dto.queue_name
        self.nodes = dto.nodes?.map { APIWorkflowNode(from: $0) } ?? []

        if let rss = dto.trigger?.rss {
            self.trigger = .rss(APIWorkflowTriggerRSS(from: rss))
        } else if let interval = dto.trigger?.interval {
            self.trigger = .interval(APIWorkflowTriggerInterval(from: interval))
        } else if let lfw = dto.trigger?.local_file_watch {
            self.trigger = .localFileWatch(APIWorkflowTriggerLocalFileWatch(from: lfw))
        } else {
            self.trigger = nil
        }

        self.createdAt = dto.created_at
        self.updatedAt = dto.updated_at
        self.lastTriggeredAt = dto.last_triggered_at ?? Date()
    }
}

public struct APIWorkflowJobTarget {
    public var entries: [String]
    public var parentEntryID: String

    public init(entries: [String], parentEntryID: String) {
        self.entries = entries
        self.parentEntryID = parentEntryID
    }

    init(from dto: WorkflowJobTargetDTO?) {
        self.entries = dto?.entries ?? []
        self.parentEntryID = dto?.parent_entry_id ?? ""
    }
}

public struct APIWorkflowJobStep: WorkflowJobStep {
    public var name: String
    public var status: String
    public var message: String

    public init(name: String, status: String, message: String) {
        self.name = name
        self.status = status
        self.message = message
    }

    init(from dto: WorkflowJobStepDTO) {
        self.name = dto.name
        self.status = dto.status
        self.message = dto.message
    }
}

public struct APIWorkflowJob: WorkflowJob {
    public var id: String
    public var workflow: String
    public var triggerReason: String
    public var status: String
    public var message: String
    public var queueName: String

    public var jobTarget: WorkflowJobTarget
    public var steps: [any WorkflowJobStep]

    public var createdAt: Date
    public var updatedAt: Date
    public var startAt: Date
    public var finishAt: Date

    public init(id: String, workflow: String, triggerReason: String, status: String, message: String, queueName: String, jobTarget: WorkflowJobTarget, steps: [any WorkflowJobStep], createdAt: Date, updatedAt: Date, startAt: Date, finishAt: Date) {
        self.id = id
        self.workflow = workflow
        self.triggerReason = triggerReason
        self.status = status
        self.message = message
        self.queueName = queueName
        self.jobTarget = jobTarget
        self.steps = steps
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.startAt = startAt
        self.finishAt = finishAt
    }

    init(from dto: WorkflowJobDTO) {
        self.id = dto.id
        self.workflow = dto.workflow
        self.triggerReason = dto.trigger_reason
        self.status = dto.status
        self.message = dto.message
        self.queueName = dto.queue_name
        self.jobTarget = WorkflowJobTarget(entries: dto.target?.entries ?? [], parentEntryID: dto.target?.parent_entry_id ?? "")
        self.steps = dto.steps?.map { APIWorkflowJobStep(from: $0) } ?? []
        self.createdAt = dto.created_at
        self.updatedAt = dto.updated_at
        self.startAt = dto.start_at ?? Date()
        self.finishAt = dto.finish_at ?? Date()
    }
}

public struct APIWorkflowJobOption {
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

    init(from option: WorkflowJobOption) {
        self.uri = option.uri
        self.reason = option.reason
        self.timeout = option.timeout
        self.parameters = option.parameters
    }
}

public struct APICreateWorkflowOption {
    public var name: String
    public var trigger: WorkflowTrigger?
    public var nodes: [any WorkflowNode]
    public var enable: Bool
    public var queueName: String?
    public var inputParameters: [WorkflowInputParameter]?

    public init(name: String, trigger: WorkflowTrigger?, nodes: [any WorkflowNode], enable: Bool = true, queueName: String? = nil, inputParameters: [WorkflowInputParameter]? = nil) {
        self.name = name
        self.trigger = trigger
        self.nodes = nodes
        self.enable = enable
        self.queueName = queueName
        self.inputParameters = inputParameters
    }

    init(from option: WorkflowCreationOption) {
        self.name = option.name
        self.trigger = option.trigger
        self.nodes = option.nodes
        self.enable = option.enable
        self.queueName = option.queueName
        self.inputParameters = option.inputParameters
    }
}
