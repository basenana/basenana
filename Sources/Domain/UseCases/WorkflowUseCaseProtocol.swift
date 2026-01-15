//
//  WorkflowUseCaseProtocol.swift
//  Domain
//
//  Created by Hypo on 2024/12/8.
//

import Foundation



public protocol WorkflowUseCaseProtocol {
    func listWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [Workflow]
    func listWorkflowJobs(workflow: String, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [WorkflowJob]
    func triggerWorkflow(_ workflow: String, option: WorkflowJobOption) async throws -> WorkflowJob
}
