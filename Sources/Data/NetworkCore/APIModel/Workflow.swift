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
    public var path: String

    public init(path: String) {
        self.path = path
    }

    init(from dto: WorkflowTriggerLocalFileWatchDTO?) {
        self.path = dto?.path ?? ""
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
    }
}

public struct APIWorkflowNodeMatrix: WorkflowNodeMatrix {
    public var data: [String: String]

    public init(data: [String: String]) {
        self.data = data
    }

    init(from dto: WorkflowNodeMatrixDTO?) {
        self.data = dto?.data ?? [:]
    }
}

public struct APIWorkflowNode: WorkflowNode {
    public var name: String
    public var type: String
    public var params: [any WorkflowNodeParam]?
    public var input: (any WorkflowNodeInput)?
    public var next: String?
    public var matrix: (any WorkflowNodeMatrix)?

    public init(name: String, type: String, params: [any WorkflowNodeParam]?, input: (any WorkflowNodeInput)?, next: String?, matrix: (any WorkflowNodeMatrix)?) {
        self.name = name
        self.type = type
        self.params = params
        self.input = input
        self.next = next
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
