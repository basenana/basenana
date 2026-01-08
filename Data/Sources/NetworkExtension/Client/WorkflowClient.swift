//
//  WorkflowClient.swift
//
//  REST API implementation of Workflow client
//

import Foundation
import Entities
import NetworkCore

public class WorkflowClient: WorkflowClientProtocol {

    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func ListWorkflows() async throws -> [NetworkCore.APIWorkflow] {
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

    public func ListWorkflowJobs(workflow: String) async throws -> [NetworkCore.APIWorkflowJob] {
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

    public func TriggerWorkflow(workflow: String, option: Entities.WorkflowJobOption) async throws -> NetworkCore.APIWorkflowJob {
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
}
