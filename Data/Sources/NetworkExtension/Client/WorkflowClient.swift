//
//  WorkflowClient.swift
//  
//
//  Created by Hypo on 2024/9/17.
//

import Foundation
import Entities
import NetworkCore


public class WorkflowClient: WorkflowClientProtocol {
    
    var client: Api_V1_WorkflowClientProtocol
    
    init(client: Api_V1_WorkflowClientProtocol) {
        self.client = client
    }
    
    public func ListWorkflows() throws -> [NetworkCore.APIWorkflow] {
        throw RepositoryError.unimplement
    }
    
    public func ListWorkflowJobs(workflow: String) throws -> [NetworkCore.APIWorkflowJob] {
        throw RepositoryError.unimplement
    }
    
    public func TriggerWorkflow(workflow: String, option: Entities.WorkflowJobOption) throws -> NetworkCore.APIWorkflowJob {
        throw RepositoryError.unimplement
    }
    
    
}
