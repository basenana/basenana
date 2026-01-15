//
//  WorkflowRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation



public protocol WorkflowRepositoryProtocol {
    func ListWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [Workflow]
    func GetWorkflow(id: String) async throws -> Workflow
    func ListWorkflowJobs(workflow: String, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [WorkflowJob]
    func TriggerWorkflow(workflow: String, option: WorkflowJobOption) async throws -> WorkflowJob
    func PauseWorkflowJob(workflowId: String, jobId: String) async throws
    func ResumeWorkflowJob(workflowId: String, jobId: String) async throws
    func CancelWorkflowJob(workflowId: String, jobId: String) async throws
}


