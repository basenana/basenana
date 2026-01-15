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

    public func listWorkflowJobs(workflow: String, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [any WorkflowJob] {
        return try await repo.ListWorkflowJobs(workflow: workflow, page: page, pageSize: pageSize, sort: sort, order: order)
    }

    public func triggerWorkflow(_ workflow: String, option: WorkflowJobOption) async throws -> WorkflowJob {
        return try await repo.TriggerWorkflow(workflow: workflow, option: option)
    }


}
