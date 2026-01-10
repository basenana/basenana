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

    public func ListWorkflows() async throws -> [APIWorkflow] {
        let response: WorkflowsResponse = try await apiClient.request(
            .workflows,
            responseType: WorkflowsResponse.self
        )

        return response.workflows.map { dto in
            APIWorkflow(
                id: dto.id,
                name: dto.name,
                executor: "",
                queueName: dto.queue_name,
                healthScore: 0,
                createdAt: dto.created_at,
                updatedAt: dto.updated_at,
                lastTriggeredAt: dto.last_triggered_at ?? Date()
            )
        }
    }

    public func ListWorkflowJobs(workflow: String) async throws -> [APIWorkflowJob] {
        let response: WorkflowJobsResponse = try await apiClient.request(
            .workflowJobs(id: workflow),
            responseType: WorkflowJobsResponse.self
        )

        return response.jobs.map { dto in
            APIWorkflowJob(
                id: dto.id,
                workflow: dto.workflow,
                triggerReason: dto.trigger_reason,
                status: dto.status,
                message: dto.message,
                executor: "",
                queueName: dto.queue_name,
                jobTarget: APIWorkflowJobTarget(entries: [], parentEntryID: 0),
                steps: dto.steps?.map { APIWorkflowJobStep(name: $0.name, status: $0.status, message: $0.message) } ?? [],
                createdAt: dto.created_at,
                updatedAt: dto.updated_at,
                startAt: dto.start_at ?? Date(),
                finishAt: dto.finish_at ?? Date()
            )
        }
    }

    public func TriggerWorkflow(workflow: String, option: WorkflowJobOption) async throws -> APIWorkflowJob {
        let request = TriggerWorkflowRequest(
            uri: nil,
            reason: nil,
            timeout: nil
        )

        let response: TriggerWorkflowResponse = try await apiClient.request(
            .workflowTrigger(id: workflow),
            body: request,
            responseType: TriggerWorkflowResponse.self
        )

        // Return a pending job with the returned job_id
        return APIWorkflowJob(
            id: response.job_id,
            workflow: workflow,
            triggerReason: "manual",
            status: "pending",
            message: "",
            executor: "",
            queueName: "",
            jobTarget: APIWorkflowJobTarget(entries: [], parentEntryID: 0),
            steps: [],
            createdAt: Date(),
            updatedAt: Date(),
            startAt: Date(),
            finishAt: Date()
        )
    }

    public func GetWorkflow(id: String) async throws -> APIWorkflow {
        let response: WorkflowDTO = try await apiClient.request(
            .workflow(id: id),
            responseType: WorkflowDTO.self
        )

        return APIWorkflow(
            id: response.id,
            name: response.name,
            executor: "",
            queueName: response.queue_name,
            healthScore: 0,
            createdAt: response.created_at,
            updatedAt: response.updated_at,
            lastTriggeredAt: response.last_triggered_at ?? Date()
        )
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

        return APIWorkflow(
            id: response.id,
            name: response.name,
            executor: "",
            queueName: response.queue_name,
            healthScore: 0,
            createdAt: response.created_at,
            updatedAt: response.updated_at,
            lastTriggeredAt: response.last_triggered_at ?? Date()
        )
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

        let dto = response.job
        return APIWorkflowJob(
            id: dto.id,
            workflow: dto.workflow,
            triggerReason: dto.trigger_reason,
            status: dto.status,
            message: dto.message,
            executor: "",
            queueName: dto.queue_name,
            jobTarget: APIWorkflowJobTarget(entries: [], parentEntryID: 0),
            steps: dto.steps?.map { APIWorkflowJobStep(name: $0.name, status: $0.status, message: $0.message) } ?? [],
            createdAt: dto.created_at,
            updatedAt: dto.updated_at,
            startAt: dto.start_at ?? Date(),
            finishAt: dto.finish_at ?? Date()
        )
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
