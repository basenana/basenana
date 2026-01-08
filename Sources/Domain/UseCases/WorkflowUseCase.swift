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
    
    public func listWorkflows() async throws -> [any  Workflow] {
        return try await repo.ListWorkflows()
    }
    
    public func listWorkflowJobs(workflow: String) async throws -> [any  WorkflowJob] {
        return try await repo.ListWorkflowJobs(workflow: workflow)
    }
    
    
}
