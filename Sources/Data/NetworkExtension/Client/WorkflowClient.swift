//
//  WorkflowClient.swift
//
//  REST API implementation of Workflow client
//

import Foundation
import Domain
import Data

public class WorkflowClient: WorkflowClientProtocol {

    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func ListWorkflows(page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [APIWorkflow] {
        let response: WorkflowsResponse = try await apiClient.request(
            .workflows(page: page, pageSize: pageSize, sort: sort, order: order),
            responseType: WorkflowsResponse.self
        )

        return response.workflows.map { APIWorkflow(from: $0) }
    }

    public func ListWorkflowJobs(workflow: String, status: [String]?, page: Int64?, pageSize: Int64?, sort: String?, order: String?) async throws -> [APIWorkflowJob] {
        let response: WorkflowJobsResponse = try await apiClient.request(
            .workflowJobs(id: workflow, status: status, page: page, pageSize: pageSize, sort: sort, order: order),
            responseType: WorkflowJobsResponse.self
        )

        return response.jobs.map { APIWorkflowJob(from: $0) }
    }

    public func TriggerWorkflow(workflow: String, option: WorkflowJobOption) async throws -> APIWorkflowJob {
        let request = TriggerWorkflowRequest(
            uri: option.uri,
            reason: option.reason,
            timeout: option.timeout
        )

        let response: TriggerWorkflowResponse = try await apiClient.request(
            .workflowTrigger(id: workflow),
            body: request,
            responseType: TriggerWorkflowResponse.self
        )

        return APIWorkflowJob(
            id: response.job_id,
            workflow: workflow,
            triggerReason: option.reason ?? "manual",
            status: "pending",
            message: "",
            queueName: "",
            jobTarget: WorkflowJobTarget(entries: [], parentEntryID: ""),
            steps: [any WorkflowJobStep](),
            createdAt: Date(),
            updatedAt: Date(),
            startAt: Date(),
            finishAt: Date()
        )
    }

    public func GetWorkflow(id: String) async throws -> APIWorkflow {
        let response: WorkflowResponse = try await apiClient.request(
            .workflow(id: id),
            responseType: WorkflowResponse.self
        )

        return APIWorkflow(from: response.workflow)
    }

    public func UpdateWorkflow(id: String, name: String?, enable: Bool?, queueName: String?) async throws -> APIWorkflow {
        let request = UpdateWorkflowRequest(
            name: name,
            enable: enable,
            queue_name: queueName
        )

        let response: WorkflowDTO = try await apiClient.request(
            .workflowUpdate(id: id),
            body: request,
            responseType: WorkflowDTO.self
        )

        return APIWorkflow(from: response)
    }

    public func DeleteWorkflow(id: String) async throws {
        _ = try await apiClient.request(
            .workflowDelete(id: id),
            responseType: DeleteWorkflowResponse.self
        )
    }

    public func GetWorkflowJob(workflowId: String, jobId: String) async throws -> APIWorkflowJob {
        let response: WorkflowJobDetailResponse = try await apiClient.request(
            .workflowJob(id: workflowId, jobId: jobId),
            responseType: WorkflowJobDetailResponse.self
        )

        return APIWorkflowJob(from: response.job)
    }

    public func PauseWorkflowJob(workflowId: String, jobId: String) async throws {
        _ = try await apiClient.request(
            .workflowJobPause(id: workflowId, jobId: jobId),
            responseType: VoidResponse.self
        )
    }

    public func ResumeWorkflowJob(workflowId: String, jobId: String) async throws {
        _ = try await apiClient.request(
            .workflowJobResume(id: workflowId, jobId: jobId),
            responseType: VoidResponse.self
        )
    }

    public func CancelWorkflowJob(workflowId: String, jobId: String) async throws {
        _ = try await apiClient.request(
            .workflowJobCancel(id: workflowId, jobId: jobId),
            responseType: VoidResponse.self
        )
    }
}
