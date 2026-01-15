//
//  WorkflowDetailViewModel.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import os
import SwiftUI
import Domain


@Observable
@MainActor
public class WorkflowDetailViewModel {
    var workflowID: String

    var workflow: WorkflowItem?
    var jobs = [JobItem]()
    var isLoading = false
    var isLoadingMore = false

    private var currentPage: Int64 = 1
    private let pageSize: Int64 = 20
    private var hasMore = true

    let usecase: any WorkflowUseCaseProtocol
    var store: StateStore

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: WorkflowDetailViewModel.self)
        )

    public init(workflow: String, store: StateStore, usecase: any WorkflowUseCaseProtocol) {
        self.workflowID = workflow
        self.store = store
        self.usecase = usecase
    }

    func initWorkflow() async {
        isLoading = true

        do {
            let workflowData = try await usecase.getWorkflow(id: workflowID)
            self.workflow = WorkflowItem(workflow: workflowData)
            Self.logger.notice("loaded workflow \(self.workflowID)")
        } catch {
            sentAlert("load workflow failed \(error)")
        }

        await loadJobs(reset: true)
        isLoading = false
    }

    func loadJobs(reset: Bool) async {
        if reset {
            jobs.removeAll()
            currentPage = 1
            hasMore = true
        }

        guard hasMore else { return }
        guard !isLoadingMore else { return }

        isLoadingMore = true

        do {
            let jobList = try await usecase.listWorkflowJobs(
                workflow: workflowID,
                page: currentPage,
                pageSize: pageSize,
                sort: "created_at",
                order: "desc"
            )
            Self.logger.notice("load workflow \(self.workflowID) jobs page \(self.currentPage), got \(jobList.count)")
            hasMore = Int64(jobList.count) >= pageSize

            for job in jobList {
                jobs.append(JobItem(job: job))
            }

            currentPage += 1
        } catch {
            sentAlert("load jobs failed \(error)")
        }

        isLoadingMore = false
    }

    func pauseJob(jobId: String) async {
        do {
            try await usecase.pauseWorkflowJob(workflowId: workflowID, jobId: jobId)
            await refreshJobStatus(jobId: jobId)
        } catch {
            sentAlert("pause job failed \(error)")
        }
    }

    func resumeJob(jobId: String) async {
        do {
            try await usecase.resumeWorkflowJob(workflowId: workflowID, jobId: jobId)
            await refreshJobStatus(jobId: jobId)
        } catch {
            sentAlert("resume job failed \(error)")
        }
    }

    func cancelJob(jobId: String) async {
        do {
            try await usecase.cancelWorkflowJob(workflowId: workflowID, jobId: jobId)
            await refreshJobStatus(jobId: jobId)
        } catch {
            sentAlert("cancel job failed \(error)")
        }
    }

    private func refreshJobStatus(jobId: String) async {
        guard let index = jobs.firstIndex(where: { $0.id == jobId }) else { return }
        do {
            let jobData = try await usecase.listWorkflowJobs(
                workflow: workflowID,
                page: 1,
                pageSize: 1,
                sort: nil,
                order: nil
            )
            if let updatedJob = jobData.first(where: { $0.id == jobId }) {
                jobs[index] = JobItem(job: updatedJob)
            }
        } catch {
        }
    }
}
