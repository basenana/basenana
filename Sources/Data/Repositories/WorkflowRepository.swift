//
//  WorkflowRepository.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Domain
import Data
import Domain


public class WorkflowRepository: WorkflowRepositoryProtocol {

    private var core: WorkflowClientProtocol

    public init(core: WorkflowClientProtocol) {
        self.core = core
    }

    public func ListWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [any Workflow] {
        return try await core.ListWorkflows(page: page, pageSize: pageSize, sort: sort, order: order)
    }

    public func GetWorkflow(id: String) async throws -> Workflow {
        return try await core.GetWorkflow(id: id)
    }

    public func CreateWorkflow(option: WorkflowCreationOption) async throws -> Workflow {
        let apiOption = APICreateWorkflowOption(from: option)
        return try await core.CreateWorkflow(option: apiOption)
    }

    public func ListWorkflowJobs(workflow: String, status: [WorkflowJobStatus]?, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [any WorkflowJob] {
        let statusStrings = status?.map { $0.rawValue }
        return try await core.ListWorkflowJobs(workflow: workflow, status: statusStrings, page: page, pageSize: pageSize, sort: sort, order: order)
    }

    public func TriggerWorkflow(workflow: String, option: WorkflowJobOption) async throws -> any WorkflowJob {
        return try await core.TriggerWorkflow(workflow: workflow, option: option)
    }

    public func PauseWorkflowJob(workflowId: String, jobId: String) async throws {
        try await core.PauseWorkflowJob(workflowId: workflowId, jobId: jobId)
    }

    public func ResumeWorkflowJob(workflowId: String, jobId: String) async throws {
        try await core.ResumeWorkflowJob(workflowId: workflowId, jobId: jobId)
    }

    public func CancelWorkflowJob(workflowId: String, jobId: String) async throws {
        try await core.CancelWorkflowJob(workflowId: workflowId, jobId: jobId)
    }
}
