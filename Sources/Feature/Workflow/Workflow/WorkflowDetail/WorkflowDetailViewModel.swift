//
//  WorkflowDetailViewModel.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import os
import SwiftUI
import Domain
import Domain
import Domain


@Observable
@MainActor
public class WorkflowDetailViewModel {
    var workflowID: String

    var workflow: WorkflowItem? = nil
    var jobs = [JobItem]()

    var store: StateStore
    var usecase: any WorkflowUseCaseProtocol

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: WorkflowDetailViewModel.self)
        )

    public init(workflow: String, store: StateStore, usecase: any WorkflowUseCaseProtocol) {
        self.workflowID = workflow
        self.store = store
        self.usecase = usecase
    }
    
    func initWorkflowJobs() async {
        jobs.removeAll()

        do {
            let jobList = try await usecase.listWorkflowJobs(workflow: workflowID, page: nil, pageSize: nil, sort: nil, order: nil)
            Self.logger.notice("load workflow \(self.workflowID) jobs, got \(jobList.count)")
            for job in jobList {
                jobs.append(JobItem(job: job))
            }
        } catch {
            sentAlert("load workflow failed \(error)")
        }
    }
}
