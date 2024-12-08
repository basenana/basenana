//
//  WorkflowClient.swift
//  
//
//  Created by Hypo on 2024/9/17.
//

import GRPC
import Foundation
import Entities
import NetworkCore


public class WorkflowClient: WorkflowClientProtocol {
    
    var client: Api_V1_WorkflowAsyncClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.workflow
    }
    
    public func ListWorkflows() async throws -> [NetworkCore.APIWorkflow] {
        
        do {
            let resp = try await client.listWorkflows(Api_V1_ListWorkflowsRequest())
            var result: [NetworkCore.APIWorkflow] = []
            for w in resp.workflows {
                result.append(w.toWorkflow())
            }
            return result
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func ListWorkflowJobs(workflow: String) async throws -> [NetworkCore.APIWorkflowJob] {
        do {
            var req = Api_V1_ListWorkflowJobsRequest()
            req.workflowID = workflow
            let resp = try await client.listWorkflowJobs(req)
            var result: [NetworkCore.APIWorkflowJob] = []
            for j in resp.jobs {
                result.append(j.toJob())
            }
            return result
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func TriggerWorkflow(workflow: String, option: Entities.WorkflowJobOption) async throws -> NetworkCore.APIWorkflowJob {
        throw RepositoryError.unimplement
    }
    
    
}
