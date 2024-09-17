//
//  WorkflowRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities


public protocol WorkflowRepositoryProtocol {
    func ListWorkflows() throws -> [Workflow]
    func ListWorkflowJobs(workflow: String) throws -> [WorkflowJob]
    func TriggerWorkflow(workflow: String, option: WorkflowJobOption) throws -> WorkflowJob
}


