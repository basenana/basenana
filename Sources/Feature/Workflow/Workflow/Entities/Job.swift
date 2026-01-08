//
//  Job.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import Domain


class JobItem: Identifiable, Equatable, Hashable {
    
    var id: String { get { info.id } }
    var status: String { get { info.status } }
    var message: String { get { info.message } }
    var startAt: Date { get {info.startAt }}
    var finishAt: Date { get {info.finishAt }}

    var info: WorkflowJob
    
    init(job: WorkflowJob){
        self.info = job
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }
    
    static func == (lhs: JobItem, rhs: JobItem) -> Bool {
        return lhs.id == rhs.id
    }
}
