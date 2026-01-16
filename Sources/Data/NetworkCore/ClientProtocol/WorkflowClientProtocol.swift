//
//  WorkflowClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Domain


public protocol WorkflowClientProtocol {
    func ListWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [APIWorkflow]
    func GetWorkflow(id: String) async throws -> APIWorkflow
    func CreateWorkflow(option: APICreateWorkflowOption) async throws -> APIWorkflow
    func UpdateWorkflow(id: String, name: String?, enable: Bool?, queueName: String?) async throws -> APIWorkflow
    func DeleteWorkflow(id: String) async throws
    func ListWorkflowJobs(workflow: String, status: [String]?, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [APIWorkflowJob]
    func GetWorkflowJob(workflowId: String, jobId: String) async throws -> APIWorkflowJob
    func PauseWorkflowJob(workflowId: String, jobId: String) async throws
    func ResumeWorkflowJob(workflowId: String, jobId: String) async throws
    func CancelWorkflowJob(workflowId: String, jobId: String) async throws
    func TriggerWorkflow(workflow: String, option: WorkflowJobOption) async throws -> APIWorkflowJob
}
