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
    var executor: String { get }
    var queueName: String { get }
    var healthScore: Int { get }
    
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var lastTriggeredAt: Date { get }
}

public protocol WorkflowJob {
    var id: String { get }
    var workflow: String { get }
    var triggerReason: String { get }
    var status: String { get }
    var message: String { get }
    var executor: String { get }
    var queueName: String { get }
    
    var jobTarget: WorkflowJobTarget { get }
    var steps: [WorkflowJobStep] { get }

    var createdAt: Date { get }
    var updatedAt: Date { get }
    var startAt: Date { get }
    var finishAt: Date { get }
}

public protocol WorkflowJobTarget {
    var entries: [Int64] { get }
    var parentEntryID: Int64 { get }
}

public protocol WorkflowJobStep {
    var name: String { get }
    var status: String { get }
    var message: String { get }
}

public struct WorkflowJobOption {
    public init() {}
}

