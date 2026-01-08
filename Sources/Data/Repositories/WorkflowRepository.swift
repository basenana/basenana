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
    
    public func ListWorkflows() async throws -> [any Workflow] {
        return try await core.ListWorkflows()
    }
    
    public func ListWorkflowJobs(workflow: String) async throws -> [any WorkflowJob] {
        return try await core.ListWorkflowJobs(workflow: workflow)
    }
    
    public func TriggerWorkflow(workflow: String, option: WorkflowJobOption) async throws -> any WorkflowJob {
        return try await core.TriggerWorkflow(workflow: workflow, option: option)
    }
}
