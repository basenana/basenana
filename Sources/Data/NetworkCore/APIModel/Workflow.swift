//
//  JobModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import Foundation
import Domain


public struct APIWorkflow: Workflow {
    public var id: String
    public var name: String
    public var executor: String
    public var queueName: String
    public var healthScore: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var lastTriggeredAt: Date
    
    public init(id: String, name: String, executor: String, queueName: String, healthScore: Int, createdAt: Date, updatedAt: Date, lastTriggeredAt: Date) {
        self.id = id
        self.name = name
        self.executor = executor
        self.queueName = queueName
        self.healthScore = healthScore
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastTriggeredAt = lastTriggeredAt
    }
}

public struct APIWorkflowJob: WorkflowJob {
    public var id: String
    public var workflow: String
    public var triggerReason: String
    public var status: String
    public var message: String
    public var executor: String
    public var queueName: String
    
    public var jobTarget: WorkflowJobTarget
    public var steps: [WorkflowJobStep]

    public var createdAt: Date
    public var updatedAt: Date
    public var startAt: Date
    public var finishAt: Date
    
    public init(id: String, workflow: String, triggerReason: String, status: String, message: String, executor: String, queueName: String, jobTarget: WorkflowJobTarget, steps: [WorkflowJobStep], createdAt: Date, updatedAt: Date, startAt: Date, finishAt: Date) {
        self.id = id
        self.workflow = workflow
        self.triggerReason = triggerReason
        self.status = status
        self.message = message
        self.executor = executor
        self.queueName = queueName
        self.jobTarget = jobTarget
        self.steps = steps
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.startAt = startAt
        self.finishAt = finishAt
    }
}

public struct APIWorkflowJobTarget: WorkflowJobTarget {
    public var entries: [Int64]
    public var parentEntryID: Int64
    
    public init(entries: [Int64], parentEntryID: Int64) {
        self.entries = entries
        self.parentEntryID = parentEntryID
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
}
