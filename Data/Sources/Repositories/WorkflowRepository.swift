//
//  WorkflowRepository.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities
import NetworkCore
import RepositoryProtocol


public class WorkflowRepository: WorkflowRepositoryProtocol {
    
    private var core: WorkflowClientProtocol
    
    init(core: WorkflowClientProtocol) {
        self.core = core
    }
    
    public func ListWorkflows() async throws -> [any Entities.Workflow] {
        return try await core.ListWorkflows()
    }
    
    public func ListWorkflowJobs(workflow: String) async throws -> [any Entities.WorkflowJob] {
        return try await core.ListWorkflowJobs(workflow: workflow)
    }
    
    public func TriggerWorkflow(workflow: String, option: Entities.WorkflowJobOption) async throws -> any Entities.WorkflowJob {
        return try await core.TriggerWorkflow(workflow: workflow, option: option)
    }
}
