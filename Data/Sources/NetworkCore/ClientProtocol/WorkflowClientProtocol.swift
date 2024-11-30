//
//  WorkflowClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol WorkflowClientProtocol {
    func ListWorkflows() async throws -> [APIWorkflow]
    func ListWorkflowJobs(workflow: String) async throws -> [APIWorkflowJob]
    func TriggerWorkflow(workflow: String, option: WorkflowJobOption) async throws -> APIWorkflowJob
}
