//
//  WorkflowClient.swift
//  
//
//  Created by Hypo on 2024/9/17.
//

import Foundation
import Entities
import NetworkCore


@available(macOS 11.0, *)
public class WorkflowClient: WorkflowClientProtocol {
    
    var client: Api_V1_WorkflowClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.workflow
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
