//
//  Workflow.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import Domain


class WorkflowItem: Identifiable, Equatable, Hashable {
    
    var id: String { get { info.id } }
    var name: String { get { info.name } }
    
    var info: Workflow
    
    init(workflow: Workflow){
        self.info = workflow
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }
    
    static func == (lhs: WorkflowItem, rhs: WorkflowItem) -> Bool {
        return lhs.id == rhs.id
    }
}
