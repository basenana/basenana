//
//  Workflow.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import Domain

class WorkflowItem: Identifiable, Equatable, Hashable {

    var id: String { info.id }
    var name: String { info.name }
    var enable: Bool { info.enable }
    var namespace: String { info.namespace }
    var queueName: String { info.queueName }
    var trigger: WorkflowTrigger? { info.trigger }
    var nodes: [any Domain.WorkflowNode] { info.nodes }

    var info: Workflow

    init(workflow: Workflow) {
        self.info = workflow
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: WorkflowItem, rhs: WorkflowItem) -> Bool {
        return lhs.id == rhs.id
    }
}
