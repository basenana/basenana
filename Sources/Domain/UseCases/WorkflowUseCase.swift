//
//  WorkflowUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/12/8.
//





public class WorkflowUseCase: WorkflowUseCaseProtocol {

    private var repo: WorkflowRepositoryProtocol
    private var entryRepo: EntryRepositoryProtocol

    public init(repo: WorkflowRepositoryProtocol, entryRepo: EntryRepositoryProtocol) {
        self.repo = repo
        self.entryRepo = entryRepo
    }

    public func listWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [any Workflow] {
        return try await repo.ListWorkflows(page: page, pageSize: pageSize, sort: sort, order: order)
    }

    public func getWorkflow(id: String) async throws -> Workflow {
        return try await repo.GetWorkflow(id: id)
    }

    public func createWorkflow(option: WorkflowCreationOption) async throws -> Workflow {
        return try await repo.CreateWorkflow(option: option)
    }

    public func listWorkflowJobs(workflow: String, status: [WorkflowJobStatus]?, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [any WorkflowJob] {
        return try await repo.ListWorkflowJobs(workflow: workflow, status: status, page: page, pageSize: pageSize, sort: sort, order: order)
    }

    public func triggerWorkflow(_ workflow: String, option: WorkflowJobOption) async throws -> WorkflowJob {
        return try await repo.TriggerWorkflow(workflow: workflow, option: option)
    }

    public func pauseWorkflowJob(workflowId: String, jobId: String) async throws {
        try await repo.PauseWorkflowJob(workflowId: workflowId, jobId: jobId)
    }

    public func resumeWorkflowJob(workflowId: String, jobId: String) async throws {
        try await repo.ResumeWorkflowJob(workflowId: workflowId, jobId: jobId)
    }

    public func cancelWorkflowJob(workflowId: String, jobId: String) async throws {
        try await repo.CancelWorkflowJob(workflowId: workflowId, jobId: jobId)
    }

    public func listWorkflowPlugins() async throws -> [WorkflowPlugin] {
        return try await repo.ListWorkflowPlugins()
    }


}
