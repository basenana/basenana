//
//  Job.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import Domain


class JobStepItem: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let status: String
    let message: String

    var statusColor: String {
        switch status {
        case "succeed": return "success"
        case "failed", "error": return "failed"
        default: return "other"
        }
    }

    init(step: any WorkflowJobStep) {
        self.id = step.name
        self.name = step.name
        self.status = step.status
        self.message = step.message
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: JobStepItem, rhs: JobStepItem) -> Bool {
        return lhs.id == rhs.id
    }
}


class JobItem: Identifiable, Equatable, Hashable {

    var id: String { get { info.id } }
    var triggerReason: String { get { info.triggerReason } }
    var status: String { get { info.status } }
    var message: String { get { info.message } }
    var createdAt: Date { get { info.createdAt } }
    var startAt: Date { get { info.startAt } }
    var finishAt: Date { get { info.finishAt } }
    var stepItems: [JobStepItem] { get { steps } }

    private let steps: [JobStepItem]

    var info: WorkflowJob

    init(job: WorkflowJob){
        self.info = job
        self.steps = job.steps.map { JobStepItem(step: $0) }
    }

    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }

    static func == (lhs: JobItem, rhs: JobItem) -> Bool {
        return lhs.id == rhs.id
    }
}
